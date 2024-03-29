//
//  AccountsTableViewController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/23.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import APIKit
import Result

enum AccountsTableType {
    case following
    case followers
//    case blocking
//    case muting
}


class AccountsTableCellData {

    let id: Int
    // not authenticated account
    let account: Account
    var relationship: Relationship?

    init(id: Int, account: Account, relationship: Relationship? = nil) {
        self.id = id
        self.account = account
        self.relationship = relationship
    }
}

/// For display Following/Followers/Blocking/Muting accounts.
class AccountsTableViewController: UITableViewController {

    var type: AccountsTableType!
    var myAccount: Account!
    var account: Account!
    var datum: [AccountsTableCellData] = []

    private let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
    private var nextMaxID: Int? {
        didSet {
            if nextMaxID == nil {
                indicator.stopAnimating()
            }
        }
    }
    private var isLoading = false
    private let limitForAPI = 80

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        tableView.register(AccountsTableViewCell.nib,
                           forCellReuseIdentifier: "accountCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension

        indicator.activityIndicatorViewStyle = .gray
        indicator.startAnimating()
        tableView.tableFooterView = indicator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchLatestAccounts() {

        switch type! {
        case .following:
            let request = MastodonAPI.GetAccountFollowingRequest(id: account.id, maxID: nil, sinceID: nil, limit: limitForAPI)
            Session.send(request) { [weak self] (result) in
                guard let s = self else { return }
                s.fetchLatestAccountsCompletion(result: result)
            }

        case .followers:
            let request = MastodonAPI.GetAccountFollowersRequest(id: account.id, maxID: nil, sinceID: nil, limit: limitForAPI)
            Session.send(request) { [weak self] (result) in
                guard let s = self else { return }
                s.fetchLatestAccountsCompletion(result: result)
            }
        }
    }

    func fetchLatestAccountsCompletion(result: Result<(accounts: [Account], sinceID: Int?, maxID: Int?), SessionTaskError>) {
        switch result {
        case .success(let (accounts, _, maxID)):
            datum = accounts.map({ AccountsTableCellData(id: $0.id, account: $0) })
            tableView.reloadData()
            if !accounts.isEmpty {
                fetchRelationships(accounts: accounts)
            }
            nextMaxID = maxID

        case .failure(let error):
            print(error)
        }
    }

    func fetchRelationships(accounts: [Account]) {

        let ids = accounts.map({ $0.id })
        let request = MastodonAPI.GetAccountRelationshipsRequest(ids: ids)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationships):
                for relationship in relationships {
                    if let data = s.datum.filter({ $0.id == relationship.id }).first {
                        data.relationship = relationship
                    }
                }
                s.tableView.reloadData()

            case .failure(let error):
                print(error)
            }
        }
    }

    private func loadMore() {
        guard let maxID = nextMaxID, !isLoading else {
            return
        }

        isLoading = true

        switch type! {
        case .following:
            let request = MastodonAPI.GetAccountFollowingRequest(id: account.id, maxID: maxID, sinceID: nil, limit: 80)
            Session.send(request) { [weak self] (result) in
                guard let s = self else { return }
                s.loadMoreCompletion(result: result)
            }

        case .followers:
            let request = MastodonAPI.GetAccountFollowersRequest(id: account.id, maxID: maxID, sinceID: nil, limit: 80)
            Session.send(request) { [weak self] (result) in
                guard let s = self else { return }
                s.loadMoreCompletion(result: result)
            }
        }
    }

    private func loadMoreCompletion(result: Result<(accounts: [Account], sinceID: Int?, maxID: Int?), SessionTaskError>) {
        switch result {
        case .success(let (accounts, _, maxID)):
            datum += accounts.map({ AccountsTableCellData(id: $0.id, account: $0) })
            tableView.reloadData()
            if !accounts.isEmpty {
                fetchRelationships(accounts: accounts)
            }
            nextMaxID = maxID

        case .failure(let error):
            print(error)
        }
        isLoading = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return datum.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountsTableViewCell
        let data = datum[indexPath.row]
        let relationship: Relationship?
        if data.account.id == myAccount.id {
            relationship = nil
        } else {
            relationship = data.relationship
        }
        cell.configureCell(follower: data.account, relationship: relationship)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= datum.count - 5 {
            loadMore()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! AccountsTableViewCell
        performSegue(withIdentifier: "Profile", sender: cell.account)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }

        switch id {

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
