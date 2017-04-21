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

    private var currentContainerViewIndex: Int!
    private var childTableViewControllers: [UITableViewController] {
        return childViewControllers.filter({ $0 is UITableViewController }) as! [UITableViewController]
    }
    private var currentChildTableViewController: UITableViewController {
        return childTableViewControllers[currentContainerViewIndex]
    }

    // For scrolling
    private var childTableViewContentInset: UIEdgeInsets {
        let insetTop = headerView.frame.maxY
        return UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
    }
    private var lastContentOffsetY: CGFloat!


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
    }


    fileprivate func switchContainerView(index: Int) {
        print("switchContainerView")

        for view in containerViews {
            view.isHidden = true

            if view.tag == index {
                view.isHidden = false
            }
        }

//        if currentContainerViewIndex != nil {
//            currentChildTableViewController.removeObserver(self, forKeyPath: "tableView.contentOffset")
//        }

        currentContainerViewIndex = index

//        // Reset headerViewTopConstraint for shown tableView
//        let tableView = currentChildTableViewController.tableView!
//        let offsetY = tableView.contentOffset.y
//        let insetTop = tableView.contentInset.top
//        let newTop = -(offsetY + insetTop)
//        let oldTop = headerViewTopConstraint.constant
//        print("old, new", oldTop, newTop)
//
//        let inset = UIEdgeInsets(top: headerView.frame.maxY, left: 0, bottom: 0, right: 0)
//        tableView.scrollIndicatorInsets = inset
//        tableView.contentInset = inset
//        if newTop < headerViewMinTopConstraint.constant {
//            headerViewTopConstraint.constant = newTop
//        }
//        lastContentOffsetY = tableView.contentOffset.y
//
//        // Observe tableView contentOffset
//        currentChildTableViewController.addObserver(self, forKeyPath: "tableView.contentOffset", options: [.new], context: nil)
    }

    private func didChangeTableViewContentOffset(tableView: UITableView) {

        let contentOffsetY = tableView.contentOffset.y
        guard lastContentOffsetY != nil else {
            lastContentOffsetY = contentOffsetY
            return
        }

        let diff = abs(contentOffsetY - lastContentOffsetY)

        var isBounce = false
        if contentOffsetY < -tableView.contentInset.top {
            isBounce = true
        }

        let isDown: Bool
        if contentOffsetY > lastContentOffsetY {
            isDown = true
        } else {
            isDown = false
        }

        let top = headerViewTopConstraint.constant
        var newTop = top
        if isDown {
            newTop = newTop - diff
        } else {
            newTop = newTop + diff
        }
        if !isBounce && newTop > 0 {
            newTop = 0
        }
        headerViewTopConstraint.constant = newTop
        print(newTop)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerView.frame.maxY, left: 0, bottom: 0, right: 0)

        lastContentOffsetY = contentOffsetY
    }

//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        guard let _ = keyPath, let obj = object else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }

//        switch obj {
//        case let tableVC as UITableViewController:
//            didChangeTableViewContentOffset(tableView: tableVC.tableView)

//        default:
//            break
//        }
//    }
}

extension ProfileViewController: ProfileMenuButtonDelegate {

    func profileMenuButtonDidTap(button: ProfileMenuButton) {

        switchContainerView(index: button.tag)
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

        default:
            break
        }
    }
}
