//
//  MainTabBarController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let homeNavigationViewController = viewControllers?[0] as! UINavigationController
        homeNavigationViewController.tabBarItem.image = UIImage(named: "tab-home")
        homeNavigationViewController.title = NSLocalizedString("home_timeline_title", comment: "")
        (homeNavigationViewController.topViewController as! TimelineTableViewController).type = .home

        let localTimelineNavigationViewController = viewControllers?[1] as! UINavigationController
        localTimelineNavigationViewController.tabBarItem.image = UIImage(named: "tab-local-timeline")
        localTimelineNavigationViewController.title = NSLocalizedString("local_timeline_title", comment: "")
        (localTimelineNavigationViewController.topViewController as! TimelineTableViewController).type = .local

        let federatedNavigationViewController = viewControllers?[2] as! UINavigationController
        federatedNavigationViewController.tabBarItem.image = UIImage(named: "tab-federated")
        federatedNavigationViewController.title = NSLocalizedString("federated_timeline_title", comment: "")
        (federatedNavigationViewController.topViewController as! TimelineTableViewController).type = .federated

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MainTabBarController.longPressed(_:)))
        tabBar.addGestureRecognizer(longPressGesture)


        NotificationCenter.default.addObserver(self,
                    selector: #selector(MainTabBarController.accountChanged(notification:)),
                    name: accountChangedNotification,
                    object: nil)

        NotificationCenter.default.addObserver(self,
                    selector: #selector(MainTabBarController.relationshipChanged(notification:)),
                    name: MastodonAPI.PostAccountBlockRequest.notificationName,
                    object: nil)

        NotificationCenter.default.addObserver(self,
                    selector: #selector(MainTabBarController.relationshipChanged(notification:)),
                    name: MastodonAPI.PostAccountUnblockRequest.notificationName,
                    object: nil)
    }

    func accountChanged(notification: Notification) {
        viewControllers?.forEach {
            ($0 as? AccountChangedRefreshable)?.shouldRefresh()
            (($0 as? UINavigationController)?.topViewController as? AccountChangedRefreshable)?.shouldRefresh()
        }
    }

    func relationshipChanged(notification: Notification) {
        viewControllers?.forEach {
            ($0 as? AccountChangedRefreshable)?.shouldRefresh()
            (($0 as? UINavigationController)?.topViewController as? AccountChangedRefreshable)?.shouldRefresh()
        }
    }

    func longPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // TODO: Implement Notifications
            // After implement: 0: Home, 1: Local, 2: Federated, 3: Notifications 4: Profile
            // Now:             0: Home, 1: Local, 2: Federated, 3: Profile
            if tabBar.selectedItem == viewControllers?[3].tabBarItem {
                performSegue(withIdentifier: "SelectAccountNavigationController", sender: self)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if MastodonAPI.accessToken == nil {
            performSegue(withIdentifier: "Login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
