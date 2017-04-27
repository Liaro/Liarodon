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
import SafariServices


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
            noteTextView.delegate = self
        }
    }
    @IBOutlet weak var noteTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreButtonView: UIView! {
        didSet {
            moreButtonView.isHidden = true
        }
    }

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
    @IBOutlet weak var requestedLabel: UILabel! {
        didSet {
            requestedLabel.isHidden = true
        }
    }
    @IBOutlet weak var blockedLabel: UILabel! {
        didSet {
            blockedLabel.isHidden = true
        }
    }
    @IBOutlet weak var blockedView: UIView! {
        didSet {
            blockedView.isHidden = true
        }
    }
    @IBOutlet weak var blockedDescriptionLabel: UILabel!
    @IBOutlet weak var viewTootsButton: UIButton! {
        didSet {
            viewTootsButton.setTitle("", for: .normal)
        }
    }

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

    fileprivate var isFollowUnfollowRequesting = false

    fileprivate var isViewDisappeared = false

    deinit {
        currentChildTableViewController.removeObserver(self, forKeyPath: "tableView.contentOffset")
    }

    var loaded = false
    override func viewDidLoad() {
        super.viewDidLoad()

        statusesButton.title = NSLocalizedString("profile_toots_tab_title", comment: "")
        followingButton.title = NSLocalizedString("profile_following_tab_title", comment: "")
        followersButton.title = NSLocalizedString("profile_followers_tab_title", comment: "")
        favouritesButton.title = NSLocalizedString("profile_favourites_tab_title", comment: "")

        initialFetch()

        NotificationCenter.default.addObserver(
            self, selector: #selector(didRecieveFollowNotification(notification:)),
            name: MastodonAPI.PostAccountFollowRequest.notificationName, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didRecieveUnfollowNotification(notification:)),
            name: MastodonAPI.PostAccountUnfollowRequest.notificationName, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didRecieveUnfollowNotification(notification:)),
            name: MastodonAPI.PostAccountBlockRequest.notificationName, object: nil)

        for button in menuButtons {
            button.delegate = self
        }
        loaded = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isViewDisappeared = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isViewDisappeared = true
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
                    s.fetchRelationship(id: id){
                        s.setupViews()
                        s.setupFollowButtonView()
                    }
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
                if s.accountID == nil {
                    // Load statusTableView at prepareForSegue for a user who is not me
                    s.statusesViewController.type = .account(s.myAccount.id)
                    s.statusesViewController.shouldRefresh()
                }
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

        if account.attributedNote.string.characters.count > 0 {
            noteTextView.attributedText = account.attributedNote
            // Displayed text will be broken during scrolling.
            // Solve it by noteLabel height = noteLabel.sizeToFit height + 1
            let fitSize = noteTextView.sizeThatFits(CGSize(width: noteTextView.bounds.width, height: view.bounds.height))
            noteTextViewHeightConstraint.constant = fitSize.height + 1
        } else {
            noteTextView.attributedText = nil
            noteTextViewHeightConstraint.constant = 0
        }

        statusesButton.value = account.statusesCount
        followingButton.value = account.followingCount
        followersButton.value = account.followersCount

        if account.id == myAccount.id {
            navigationItem.title = NSLocalizedString("profile_title", comment: "")
            // TODO: GET /api/v1/favourites and count [Status]
            // Not implemented yet
            favouritesButton.value = 0
            favouritesButton.isHidden = true

            followButtonView.isHidden = true
            moreButtonView.isHidden = true
        } else {
            navigationItem.title = account.displayName
            favouritesButton.isHidden = true
            moreButtonView.isHidden = false
        }


        let localized = NSLocalizedString("profile_blocked_description", comment: "")
        blockedDescriptionLabel.text = String(format: localized, "@" + account.username)
        viewTootsButton.setTitle(NSLocalizedString("profile_view_toots_button_title", comment: ""), for: .normal)
        if let relationship = relationship, relationship.blocking {
            blockedView.isHidden = false
        } else {
            blockedView.isHidden = true
        }

        for vc in childTableViewControllers {
            if let accountsVC = vc as? AccountsTableViewController {
                accountsVC.myAccount = myAccount
                accountsVC.account = account
                accountsVC.fetchLatestAccounts()
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

    fileprivate func setupFollowButtonView() {
        guard let relationship = relationship else {
            return
        }
        followButton.isHidden = false
        blockedLabel.isHidden = true
        blockedView.isHidden = true

        if relationship.requested {
            followButton.type = .cancelRequest
            requestedLabel.isHidden = false
        } else if relationship.blocking {
            followButton.isHidden = true
            blockedLabel.isHidden = false
            blockedView.isHidden = false
        }
        else if relationship.following {
            followButton.type = .unfollow
            requestedLabel.isHidden = true
        } else {
            followButton.type = .follow
            requestedLabel.isHidden = true
        }
        followButtonView.isHidden = false
    }

    @IBAction func viewTootsButtonDidTap(_ sender: UIButton) {

        blockedView.isHidden = true
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
        if loaded {
            // if the method calls before loaded, it crash
            initialFetch()
        }
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

        if isViewDisappeared {
            followingViewController.fetchLatestAccounts()
            followersViewController.fetchLatestAccounts()
        }
    }

    func didRecieveUnfollowNotification(notification: Notification) {
        guard account.id == myAccount.id else {
            return
        }

        myAccount.followingCount -= 1
        followingButton.value = myAccount.followingCount

        if isViewDisappeared {
            followingViewController.fetchLatestAccounts()
            followersViewController.fetchLatestAccounts()
        }
    }
}

extension ProfileViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        // for iOS9
        if #available(iOS 10.0, *) {
        } else {
            interact(withURL: URL)
        }
        return false
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction != .invokeDefaultAction {
            // Prevent 3D Touch actions: http://stackoverflow.com/questions/40090138/shouldinteractwithurl-called-twice-on-3d-touch
            return false
        }

        interact(withURL: URL)

        return false
    }

    private func interact(withURL URL: URL) {

        let safariViewController = SFSafariViewController(url: URL)
        present(safariViewController, animated: true, completion: nil)
    }
}

// MARK: - ProfileHeaderView button actions
extension ProfileViewController {

    @IBAction func followButtonDidTap(_ sender: FollowButton) {

        guard !isFollowUnfollowRequesting else {
            return
        }

        switch sender.type {

        case .follow:
            follow()

        case .unfollow:
            unfollow()

        case .cancelRequest:
            // TODO: Follow request senders cannot cancel?
            // I tried POST unfollow, but relationship.requested was 1.
            // I don't know how cancel.
            break
        }
    }

    private func follow() {

        isFollowUnfollowRequesting = true

        let request = MastodonAPI.PostAccountFollowRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationship):
                if relationship.following {
                    s.followButton.type = .unfollow
                } else if relationship.requested {
                    s.followButton.type = .cancelRequest
                }

            case .failure(let error):
                print(error)
            }

            s.isFollowUnfollowRequesting = false
        }
    }

    private func unfollow(isCancelRequest: Bool = false) {

        isFollowUnfollowRequesting = true

        let request = MastodonAPI.PostAccountUnfollowRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success( _):
                s.followButton.type = .follow

            case .failure(let error):
                print(error)
            }
            
            s.isFollowUnfollowRequesting = false
        }
    }

    @IBAction func moreButtonDidTap(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds

        let block = UIAlertAction(title: NSLocalizedString("block_user_action_title", comment: ""), style: .destructive) { (action) in
            self.block()
        }
        let unblock = UIAlertAction(title: NSLocalizedString("unblock_user_action_title", comment: ""), style: .default) { (action) in
            self.unblock()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)

        if let relationship = relationship {
            if relationship.blocking {
                alert.addAction(unblock)
            } else {
                alert.addAction(block)
            }
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    private func block() {

        let request = MastodonAPI.PostAccountBlockRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationship):
                s.relationship = relationship
                s.setupFollowButtonView()

            case .failure(let error):
                print(error)
            }
        }
    }

    private func unblock() {

        let request = MastodonAPI.PostAccountUnblockRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationship):
                s.relationship = relationship
                s.setupFollowButtonView()

            case .failure(let error):
                print(error)
            }
        }
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
            if let accountID = accountID {
                timelineVC.type = .account(accountID)
            } else {
                // In case accountID is not exists, the method called and should set any type to ViewController
                // I added ID 0 account (not exist account) for now, but it MUST be fixed. FIXME
                timelineVC.type = .account(0)
            }
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
            favouritesViewController = timelineVC
            favouritesViewController.type = .home

        default:
            break
        }
    }
}
