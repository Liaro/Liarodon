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
        homeNavigationViewController.title = "Home"

        let localTimelineNavigationViewController = viewControllers?[1] as! UINavigationController
        localTimelineNavigationViewController.tabBarItem.image = UIImage(named: "tab-local-timeline")
        localTimelineNavigationViewController.title = "Local"

        let federatedNavigationViewController = viewControllers?[2] as! UINavigationController
        federatedNavigationViewController.tabBarItem.image = UIImage(named: "tab-federated")
        federatedNavigationViewController.title = "Federated"
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
