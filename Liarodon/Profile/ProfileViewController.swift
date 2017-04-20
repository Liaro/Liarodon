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

    private var account: Account!

    @IBOutlet weak var headerView: ProfileHeaderView!
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

    /// Child view controllers
    fileprivate weak var followingTableViewController: FollowingTableViewController! {
        didSet {
            followingTableViewController.addObserver(self, forKeyPath: "tableView.contentOffset", options: [.initial, .new], context: nil)
        }
    }
    fileprivate weak var followersTableViewController: FollowersTableViewController!

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
        }


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let insetTop = headerView.frame.maxY
        let inset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
        followingTableViewController.tableView.contentInset = inset
        followingTableViewController.tableView.scrollIndicatorInsets = inset
        followingTableViewController.tableView.contentOffset = CGPoint(x: 0, y: -insetTop)

        lastContentOffsetY = followingTableViewController.tableView.contentOffset.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func requestCompletion(result: Result<Account, SessionTaskError>) {

        switch result {

        case .success(let account):
            self.account = account
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
    }

    private func didChangeTableViewContentOffset(tableView: UITableView) {

        guard lastContentOffsetY != nil else {
            return
        }

        let contentOffsetY = tableView.contentOffset.y
        let diff = abs(contentOffsetY - lastContentOffsetY)
        let isDown: Bool // scroll to down or up
        var isBounce = false
        if contentOffsetY < -tableView.contentInset.top {
            isBounce = true
        }
        if contentOffsetY > lastContentOffsetY {
            isDown = true
        } else {
            isDown = false
        }

        var newTop = headerViewTopConstraint.constant
        if isDown {
            newTop = newTop - diff
        } else {
            newTop = newTop + diff
        }
        if !isBounce && newTop > 0 {
            newTop = 0
        }
        headerViewTopConstraint.constant = newTop

        // About 30: topLayouGuide.length is too long. 30 is good. But I don't know why 30.
        let newInsetTop = max(headerView.frame.maxY, 30)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: newInsetTop, left: 0, bottom: 0, right: 0)

        lastContentOffsetY = contentOffsetY
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard let key = keyPath, let obj = object else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        switch obj {
        case let followingVC as FollowingTableViewController:
            didChangeTableViewContentOffset(tableView: followingVC.tableView)

        default:
            break
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

        case "Timeline":
            guard let timelineVC = segue.destination as? TimelineTableViewController else {
                return
            }
            // TODO: .home => .account
            timelineVC.type = .home


        case "Following":
            guard let followingVC = segue.destination as? FollowingTableViewController else {
                return
            }
            followingTableViewController = followingVC
        default:
            break
        }
    }
}
