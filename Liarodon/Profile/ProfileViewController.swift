//
//  ProfileViewController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import APIKit
import Result
import Kingfisher


final class ProfileViewController: UIViewController {

    // Display authenticated account if nil.
    var accountID: Int? = nil

    /// Authenticated account
    fileprivate var myAccount: Account!
    /// Display account
    fileprivate var account: Account!
    /// If myAccount is not account, use relationship.
    fileprivate var relationship: Relationship?

    @IBOutlet weak var headerView: ProfileHeaderView!
    @IBOutlet weak var headerViewMinTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel! {
        didSet {
            displayNameLabel.text = ""
        }
    }
    @IBOutlet private weak var acctLabel: UILabel! {
        didSet {
            acctLabel.text = ""
        }
    }
    @IBOutlet weak var noteTextView: LinkTextView! {
        didSet {
            noteTextView.text = ""
        }
    }
    @IBOutlet weak var noteTextViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var statusesButton: ProfileMenuButton!
    @IBOutlet weak var followingButton: ProfileMenuButton!
    @IBOutlet weak var followersButton: ProfileMenuButton!
    @IBOutlet weak var favouritesButton: ProfileMenuButton!
    private var menuButtons: [ProfileMenuButton] {
        return [
            statusesButton,
            followingButton,
            followersButton,
            favouritesButton
        ]
    }
    @IBOutlet weak var followButtonView: UIView!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var requestedLabel: UILabel!

    @IBOutlet weak var statusesContainerView: UIView!
    @IBOutlet weak var followingContainerView: UIView!
    @IBOutlet weak var followersContainerView: UIView!
    @IBOutlet weak var favouritesContainerView: UIView!
    fileprivate var containerViews: [UIView] {
        return [
            statusesContainerView,
            followingContainerView,
            followersContainerView,
            favouritesContainerView
        ]
    }
    fileprivate var statusesViewController: TimelineTableViewController!
    fileprivate var followingViewController: AccountsTableViewController!
    fileprivate var followersViewController: AccountsTableViewController!
    fileprivate var favouritesViewController: TimelineTableViewController!
    fileprivate var childTableViewControllers: [UITableViewController] {
        return [
            statusesViewController,
            followingViewController,
            followersViewController,
            favouritesViewController
        ]
    }
    fileprivate var currentContainerViewIndex: Int!

    fileprivate var currentChildTableViewController: UITableViewController {
        return childTableViewControllers[currentContainerViewIndex]
    }

    // For scrolling
    fileprivate var lastContentOffsetY: CGFloat!

    deinit {
        currentChildTableViewController.removeObserver(self, forKeyPath: "tableView.contentOffset")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialFetch()

        NotificationCenter.default.addObserver(
            self, selector: #selector(didRecieveFollowNotification(notification:)),
            name: MastodonAPI.PostAccountFollowRequest.notificationName, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didRecieveUnfollowNotification(notification:)),
            name: MastodonAPI.PostAccountUnfollowRequest.notificationName, object: nil)

        for button in menuButtons {
            button.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initialFetch() {
        fetchAuthenticatedAccount { [weak self] in
            guard let s = self else { return }

            if let id = s.accountID, id != s.myAccount.id {
                s.fetchAccount(id: id) {
                    s.setupViews()
                }
                s.fetchRelationship(id: id){
                    s.setupFollowButtonView()
                }
            } else {
                s.account = s.myAccount
                s.setupViews()
            }
        }
    }

    private func fetchAuthenticatedAccount(completion: @escaping () -> Void) {
        let request = MastodonAPI.GetAuthenticatedAccountRequest()
        Session.send(request) { [weak self] result in
            guard let s = self else { return }

            switch result {

            case .success(let account):
                s.myAccount = account
                completion()

            case .failure(let error):
                // TODO: GET Account failure
                print(error)
            }
        }
    }

    private func fetchAccount(id: Int, completion: @escaping () -> Void) {
        let request = MastodonAPI.GetAccountRequest(id: id)
        Session.send(request) { [weak self] result in
            guard let s = self else { return }

            switch result {

            case .success(let account):
                s.account = account
                completion()

            case .failure(let error):
                // TODO: GET Account failure
                print(error)
            }
        }
    }

    func fetchRelationship(id: Int, completion: @escaping () -> Void) {

        let request = MastodonAPI.GetAccountRelationshipsRequest(ids: [id])
        Session.send(request) { [weak self] (result) in
            guard let s = self else { return }

            switch result {

            case .success(let relationships):
                s.relationship = relationships.first
                completion()

            case .failure(let error):
                print(error)
            }
        }
    }

    private func setupViews() {
        print(account)
        avatarImageView.kf.setImage(with: account.avatar.url)
        headerImageView.kf.setImage(with: account.header.url) { [weak self] image, _, _, url in
            guard let s = self else { return }
            let color: UIColor
            if let url = url, url.absoluteString.contains("missing") {
                color = .clear
            }
            else if image != nil {
                color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            } else {
                color = .clear
            }
            s.displayNameLabel.backgroundColor = color
            s.acctLabel.backgroundColor = color
            s.noteTextView.backgroundColor = color
        }
        displayNameLabel.text = account.displayName
        acctLabel.text = "@" + account.acct

        // Displayed text will be broken during scrolling.
        // Solve it by noteLabel height = noteLabel.sizeToFit height + 1
        noteTextView.attributedText = account.attributedNote
        let fitSize = noteTextView.sizeThatFits(CGSize(width: noteTextView.bounds.width, height: view.bounds.height))
        noteTextViewHeightConstraint.constant = fitSize.height + 1

        statusesButton.value = account.statusesCount
        followingButton.value = account.followingCount
        followersButton.value = account.followersCount

        if account.id == myAccount.id {
            // TODO: GET /api/v1/favourites and count [Status]
            favouritesButton.value = 0
            favouritesButton.isHidden = false
            followButtonView.isHidden = true
        } else {
            navigationItem.title = account.displayName
            favouritesButton.isHidden = true
        }

        for vc in childTableViewControllers {
            if let accountsVC = vc as? AccountsTableViewController {
                accountsVC.myAccount = myAccount
                accountsVC.account = account
                accountsVC.fetchLatestAccounts()
                accountsVC.deleagte = self
            }
        }

        // Determine headerView height
        view.layoutIfNeeded()

        headerViewMinTopConstraint.constant = -(headerView.bounds.height - menuView.bounds.height)

        if currentContainerViewIndex == nil {
            let insetTop = headerView.frame.maxY
            let inset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
            for tableViewController in childTableViewControllers {
                tableViewController.tableView.contentInset = inset
                tableViewController.tableView.scrollIndicatorInsets = inset
                tableViewController.tableView.contentOffset = CGPoint(x: 0, y: -insetTop)
            }
            switchContainerView(index: 0)
        } else {
            if let accountsVC = currentChildTableViewController as? AccountsTableViewController {
                accountsVC.fetchLatestAccounts()
            }
        }
    }

    private func setupFollowButtonView() {
        guard let relationship = relationship else {
            return
        }
        if relationship.requested {
            followButton.type = .cancelRequest
            requestedLabel.isHidden = false
        } else if relationship.following {
            followButton.type = .unfollow
            requestedLabel.isHidden = true
        } else {
            followButton.type = .follow
            requestedLabel.isHidden = true
        }
        followButtonView.isHidden = false
    }

    fileprivate func switchContainerView(index: Int) {

        for view in containerViews {
            view.isHidden = view.tag != index
        }

        if currentContainerViewIndex != nil {
            currentChildTableViewController.removeObserver(self, forKeyPath: "tableView.contentOffset")
        }
        currentContainerViewIndex = index

        let tableView = currentChildTableViewController.tableView!
        let offsetY = tableView.contentOffset.y
        let insetTop = tableView.contentInset.top
        let headerNewTop = -(offsetY + insetTop)
        headerViewTopConstraint.constant = headerNewTop

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let s = self else { return }
            s.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let s = self else { return }
            s.lastContentOffsetY = tableView.contentOffset.y
            s.currentChildTableViewController.addObserver(s, forKeyPath: "tableView.contentOffset", options: [.new], context: nil)
        })

        if let accountsVC = currentChildTableViewController as? AccountsTableViewController {
            accountsVC.fetchLatestAccounts()
        }
    }
}

// MARK: - AccountChangedRefreshable
extension ProfileViewController: AccountChangedRefreshable {

    func shouldRefresh() {

        initialFetch()
    }
}

// MARK: - KVO
extension ProfileViewController {

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard let _ = keyPath, let obj = object else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        switch obj {
        case let tableVC as UITableViewController:
            didChangeTableViewContentOffset(tableView: tableVC.tableView)

        default:
            break
        }
    }

    private func didChangeTableViewContentOffset(tableView: UITableView) {

        let contentOffsetY = tableView.contentOffset.y
        guard lastContentOffsetY != nil else {
            lastContentOffsetY = contentOffsetY
            return
        }


        var isBounce = false
        if contentOffsetY < -tableView.contentInset.top {
            isBounce = true
        }

        var diff = abs(contentOffsetY - lastContentOffsetY)
        if contentOffsetY > lastContentOffsetY {
            diff = -diff
        }

        let top = headerViewTopConstraint.constant
        var newTop = top + diff
        if !isBounce && newTop > 0 {
            newTop = 0
        }
        headerViewTopConstraint.constant = newTop

        tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerView.frame.maxY, left: 0, bottom: 0, right: 0)

        lastContentOffsetY = contentOffsetY
    }
}

// MARK: - ProfileMenuButtonDelegate
extension ProfileViewController: ProfileMenuButtonDelegate {

    func profileMenuButtonDidTap(button: ProfileMenuButton) {

        guard currentContainerViewIndex != button.tag else {
            return
        }
        switchContainerView(index: button.tag)
    }
}

// MARK: - Follow/Unfollow Notification Observer
extension ProfileViewController {

    func didRecieveFollowNotification(notification: Notification) {
        guard account.id == myAccount.id else {
            return
        }

        myAccount.followingCount += 1
        followingButton.value = myAccount.followingCount
    }

    func didRecieveUnfollowNotification(notification: Notification) {
        guard account.id == myAccount.id else {
            return
        }

        myAccount.followingCount -= 1
        followingButton.value = myAccount.followingCount
    }
}

// MARK: - AccountsTableViewControllerDelegate
extension ProfileViewController: AccountsTableViewControllerDelegate {

    func accountsTableViewControllerDidSelectAccount(viewController: AccountsTableViewController, account: Account) {

        performSegue(withIdentifier: "Profile", sender: account)
    }
}

// MARK: - Navigation
extension ProfileViewController {

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }

        switch id {

        case "Statuses":
            guard let timelineVC = segue.destination as? TimelineTableViewController else {
                return
            }
            // TODO: .home => .account
            timelineVC.type = .home
            statusesViewController = timelineVC

        case "Following":
            guard let accountsVC = segue.destination as? AccountsTableViewController else {
                return
            }
            accountsVC.type = .following
            followingViewController = accountsVC

        case "Followers":
            guard let accountsVC = segue.destination as? AccountsTableViewController else {
                return
            }
            accountsVC.type = .followers
            followersViewController = accountsVC

        case "Favourites":
            guard let timelineVC = segue.destination as? TimelineTableViewController else {
                return
            }
            // TODO: .home => .favourites
            timelineVC.type = .home
            favouritesViewController = timelineVC

        case "Profile":
            guard let profileVC = segue.destination as? ProfileViewController else {
                return
            }
            guard let account = sender as? Account else {
                return
            }
            profileVC.accountID = account.id

        default:
            break
        }
    }
}
