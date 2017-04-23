//
//  AccountService.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import Foundation
import KeychainAccess


struct LoginAccount {
    let key: String
    let host: String
    let username: String
    let displayName: String
    let avaterUrl: String
    init?(key: String, accountData: [String: String]) {
        self.key = key
        self.host = accountData["host"] ?? ""
        self.username = accountData["username"] ?? ""
        self.displayName = accountData["displayName"] ?? ""
        self.avaterUrl = accountData["avaterUrl"] ?? ""
    }
}


let accountChangedNotification = NSNotification.Name(rawValue: "accountChangedNotification")

class AccountService {
    static let shared = AccountService()

    func setupAccount() {
        // Setup MastodonAPI
        let keychain = Keychain()
        do {
            if let instanceURL = try keychain.get("instance_url") {
                MastodonAPI.instanceURL = instanceURL.url
            }
            if let accessToken = try keychain.get("access_token") {
                MastodonAPI.accessToken = accessToken
            }
        } catch {}
    }

    func setInstanceUrl(_ instanceUrl: String) {
        let keychain = Keychain()
        keychain["instance_url"] = instanceUrl
        // Setup MastodonAPI
        MastodonAPI.instanceURL = instanceUrl.url
    }

    func setAccessToken(_ accessToken: String) {
        // Store access token
        let keychain = Keychain()
        keychain["access_token"] = accessToken

        // Setup MastodonAPI
        MastodonAPI.accessToken = accessToken
    }

    func addAccount(accessToken: String, username: String, displayName: String, avaterUrl: String, host: String, accountId: Int) -> LoginAccount? {
        let keychain = Keychain()

        let key = "\(host)-\(accountId)"
        keychain["access_token-\(key)"] = accessToken

        let accounts = UserDefaults.standard.value(forKey: "accounts") as? [String] ?? []

        let addedAccounts = NSOrderedSet(array: accounts + [key]).array as! [String]
        UserDefaults.standard.setValue(addedAccounts, forKey: "accounts")

        let accountData = [
            "username": username,
            "displayName": displayName,
            "avaterUrl": avaterUrl,
            "host": host,
        ]

        UserDefaults.standard.setValue(accountData, forKey: key)
        UserDefaults.standard.synchronize()

        return LoginAccount(key: key, accountData: accountData)
    }

    func getAccounts() -> [LoginAccount] {
        guard let accounts = UserDefaults.standard.value(forKey: "accounts") as? [String] else {
            return []
        }

        let loginAccounts = accounts.flatMap { account -> LoginAccount? in
            guard let accountData = UserDefaults.standard.value(forKey: account) as? [String: String] else { return nil }
            return LoginAccount(key: account, accountData: accountData)
        }

        return loginAccounts
    }

    func selectAccount(_ account: LoginAccount) -> Bool {
        let keychain = Keychain()

        guard let accessTokenOptional = try? keychain.get("access_token-\(account.key)"), let accessToken = accessTokenOptional else {
            return false
        }

        UserDefaults.standard.setValue(account.key, forKey: "selectedAccountKey")
        UserDefaults.standard.synchronize()
        setAccessToken(accessToken)
        setInstanceUrl(account.host)

        return true
    }

    func getSelectedAccount() -> LoginAccount? {
        guard let account = UserDefaults.standard.value(forKey: "selectedAccountKey") as? String else { return nil }
        guard let accountData = UserDefaults.standard.value(forKey: account) as? [String: String] else { return nil }
        return LoginAccount(key: account, accountData: accountData)
    }
}
