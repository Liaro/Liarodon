//
//  AppDelegate.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import APIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Example for use MastodonAPI.
        /*
        MastodonAPI.instanceURL = URL(string: "https://mstdn.jp")!
        let req = MastodonAPI.PostAppsRequest(clientName: "131e55")
        Session.send(req) { (result) in
            switch result {
            case .success(let app):
                print(app)
                let req = MastodonAPI.PostAccessTokenRequest(
                    clientID: app.clientID,
                    clientSecret: app.clientSecret,
                    username: "131e550807@gmail.com",
                    password: "kei9218080756"
                )
                Session.send(req, callbackQueue: nil) { (result) in
                    switch result {
                    case .success(let accessToken):
                        print(accessToken)
                        MastodonAPI.accessToken = accessToken.accessToken

                        let req = MastodonAPI.GetAuthenticatedAccountRequest()
                        Session.send(req, callbackQueue: nil) { (result) in
                            switch result {
                            case .success(let account):
                                print(account)

                            case .failure(let error):
                                print(error)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        */

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

