//
//  FollowersTableViewController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import APIKit


private class Follower {

    let id: Int
    let account: Account
    var relationship: Relationship?

    init(id: Int, account: Account, relationship: Relationship? = nil) {
        self.id = id
        self.account = account
        self.relationship = relationship
    }
}

final class FollowersTableViewController: UITableViewController {

    var account: Account! {
        didSet {
            fetchLatestFollowers()
        }
    }

    // Array index is mutual sharing.
    private var followers: [Follower] = []
    private var accounts: [Account] = []
    private var relationships: [Relationship] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        tableView.register(AccountsTableViewCell.nib, forCellReuseIdentifier: "accountCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchLatestFollowers() {

        let request = MastodonAPI.GetAccountFollowersRequest(id: account.id, maxID: nil, sinceID: nil, limit: 80)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let accounts):
                s.followers = accounts.map({ Follower(id: $0.id, account: $0) })
                s.accounts = accounts
                s.tableView.reloadData()
                s.fetchRelationships(accounts: accounts)

            case .failure(let error):
                print(error)
            }
        }
    }


    private func fetchRelationships(accounts: [Account]) {

        let ids = accounts.map({ $0.id })
        let request = MastodonAPI.GetAccountRelationshipsRequest(ids: ids)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationships):
                for relationship in relationships {
                    if let follower = s.followers.filter({ $0.id == relationship.id }).first {
                        follower.relationship = relationship
                    }
                }
                s.tableView.reloadData()

            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return followers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountsTableViewCell
        let follower = followers[indexPath.row]
        cell.configureCell(follower: follower.account, relationship: follower.relationship)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
