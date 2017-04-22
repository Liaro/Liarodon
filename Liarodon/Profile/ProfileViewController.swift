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

    fileprivate var account: Account!
    fileprivate var mutableFollowingCount = 0

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
    @IBOutlet var containerViews: [UIView]!

    fileprivate var currentContainerViewIndex: Int!
    fileprivate var childTableViewControllers: [UITableViewController] {
        return childViewControllers.filter({ $0 is UITableViewController }) as! [UITableViewController]
    }
    fileprivate var currentChildTableViewController: UITableViewController {
        return childTableViewControllers[currentContainerViewIndex]
    }

    // For scrolling
    fileprivate var lastContentOffsetY: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = accountID {
            let request = MastodonAPI.GetAccountRequest(id: id)
            Session.send(request) { [weak self] result in
                self?.requestCompletion(result: result)
            }
        } else {
            let request = MastodonAPI.GetAuthenticatedAccountRequest()
            Session.send(request) { [weak self] result in
                self?.requestCompletion(result: result)
            }

            NotificationCenter.default.addObserver(
                self, selector: #selector(didRecieveFollowNotification(notification:)),
                name: MastodonAPI.PostAccountFollowRequest.notificationName, object: nil)
            NotificationCenter.default.addObserver(
                self, selector: #selector(didRecieveUnfollowNotification(notification:)),
                name: MastodonAPI.PostAccountUnfollowRequest.notificationName, object: nil)
        }

        for button in menuButtons {
            button.delegate = self
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        headerViewMinTopConstraint.constant = -(headerView.bounds.height - menuView.bounds.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let insetTop = headerView.frame.maxY
        let inset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
        for tableViewController in childTableViewControllers {
            tableViewController.tableView.contentInset = inset
            tableViewController.tableView.scrollIndicatorInsets = inset
            tableViewController.tableView.contentOffset = CGPoint(x: 0, y: -insetTop)
        }

        if currentContainerViewIndex == nil {
            switchContainerView(index: 0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func requestCompletion(result: Result<Account, SessionTaskError>) {

        switch result {

        case .success(let account):
            self.account = account
            mutableFollowingCount = account.followingCount
            setupViews()
            print(account)

        case .failure(let error):
            // TODO: GET Account failure
            print(error)
        }
    }

    private func setupViews() {

        headerImageView.kf.setImage(with: account.header.url)
        avatarImageView.kf.setImage(with: account.avatar.url)
        displayNameLabel.text = account.displayName
        acctLabel.text = "@" + account.acct
        statusesButton.value = account.statusesCount
        followingButton.value = account.followingCount
        followersButton.value = account.followersCount
        // TODO: GET /api/v1/favourites and count [Status]
        favouritesButton.value = 0

        for vc in childTableViewControllers {
            switch vc {

            case let following as FollowingTableViewController:
                following.account = account

            case let followers as FollowersTableViewController:
                followers.account = account

            default:
                break
            }
        }
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

        if let followingVC = currentChildTableViewController as? FollowingTableViewController {
            followingVC.fetchLatestFollowing()
        }
        else if let followersVC = currentChildTableViewController as? FollowersTableViewController {
            followersVC.fetchLatestFollowers()
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
//        if isBounce {
//            if top < newTop {
//                headerViewTopConstraint.constant = newTop
//            } else {
//                // do nothing
//            }
//        } else {
//        }
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

        mutableFollowingCount += 1
        followingButton.value = mutableFollowingCount

        if let followingVC = childTableViewControllers.filter({ $0 is FollowingTableViewController }).first as? FollowingTableViewController {
            followingVC.fetchLatestFollowing()
        }
    }

    func didRecieveUnfollowNotification(notification: Notification) {

        mutableFollowingCount -= 1
        followingButton.value = mutableFollowingCount

        if let followersVC = childTableViewControllers.filter({ $0 is FollowersTableViewController }).first as? FollowersTableViewController {
            followersVC.fetchLatestFollowers()
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
            // TODO: .home => .account
            timelineVC.type = .home

        case "Favourites":
            guard let timelineVC = segue.destination as? TimelineTableViewController else {
                return
            }
            // TODO: .home => .favourites
            timelineVC.type = .home

        default:
            break
        }
    }
}
