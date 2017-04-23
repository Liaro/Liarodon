//
//  SelectAccountTableViewController.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import Kingfisher
import KeychainAccess

class SelectAccountTableViewController: UITableViewController {

    var accounts = [LoginAccount]()

    override func viewDidLoad() {
        super.viewDidLoad()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.accounts = AccountService.shared.getAccounts()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0..<accounts.count:
            let account = accounts[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
            // cell.imageView?.kf.setImage(with: URL(string: ""))
            cell.textLabel?.text = account.displayName
            cell.detailTextLabel?.text = "@\(account.username)@\(account.host)"
            cell.imageView?.kf.setImage(with: account.avaterUrl.url)
            if AccountService.shared.getSelectedAccount()?.key == account.key {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case accounts.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCell", for: indexPath)
            return cell
        case accounts.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
            return cell
        default:
            fatalError("No cell found in SelectAccountTableViewController")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0..<accounts.count:
            let account = accounts[indexPath.row]
            _ = AccountService.shared.selectAccount(account)
            let notification = Notification(
                name: accountChangedNotification,
                object: self,
                userInfo: nil)
            NotificationCenter.default.post(notification)

            tableView.reloadData()
        case accounts.count:
            break
        case accounts.count + 1:
            break
        default:
            fatalError("No cell found in SelectAccountTableViewController")
        }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Login" {
            (segue.destination as! LoginViewController).showCloseButton = true
        }
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
