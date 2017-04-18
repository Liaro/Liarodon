//
//  Account.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki


final class Account {

    /// The ID of the account.
    let id: Int
    /// The username of the account.
    let username: String
    /// Equals username for local users, includes @domain for remote ones.
    let acct: String
    /// The account's display name.
    let displayName: String
    /// Boolean for when the account cannot be followed without waiting for approval first.
    let locked: Bool
    /// The time the account was created.
    let createdAt: String
    /// The number of followers for the account.
    let followersCount: Int
    /// The number of accounts the given account is following.
    let followingCount: Int
    /// The number of statuses the account has made.
    let statusesCount: Int
    /// Biography of user.
    let note: String
    /// URL of the user's profile page (can be remote).
    let url: URL
    /// URL to the avatar image.
    let avatar: URL
    ///URL to the avatar static image (gif)
    let avatarStatic: URL
    /// URL to the header image.
    let header: URL
    /// URL to the header static image (gif)
    let headerStatic: URL


    init(id: Int, username: String, acct: String, displayName: String,
         locked: Bool, createdAt: String, followersCount: Int, followingCount: Int,
         statusesCount: Int, note: String, url: URL, avatar: URL, avatarStatic: URL,
         header: URL, headerStatic: URL) {

        self.id = id
        self.username = username
        self.acct = acct
        self.displayName = displayName
        self.locked = locked
        self.createdAt = createdAt
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.statusesCount = statusesCount
        self.note = note
        self.url = url
        self.avatar = avatar
        self.avatarStatic = avatarStatic
        self.header = header
        self.headerStatic = headerStatic
    }
}

extension Account: Decodable {

    static func decode(_ e: Extractor) throws -> Account {

        return try Account(
            id              : e <| "id",
            username        : e <| "username",
            acct            : e <| "acct",
            displayName     : e <| "display_name",
            locked          : e <| "locked",
            createdAt       : e <| "created_at",
            followersCount  : e <| "followers_count",
            followingCount  : e <| "following_count",
            statusesCount   : e <| "statuses_count",
            note            : e <| "note",
            url             : URL(string: try e <| "url")!,
            avatar          : URL(string: try e <| "avatar")!,
            avatarStatic    : URL(string: try e <| "avatar_static")!,
            header          : URL(string: try e <| "header")!,
            headerStatic    : URL(string: try e <| "header_static")!
        )
    }
}

extension Account: CustomStringConvertible {

    var description: String {
        return
            "{\n" +
            "  id: \(id),\n" +
            "  username: \(username),\n" +
            "  acct: \(acct), \n" +
            "  displayName: \(displayName),\n" +
            "}"
    }
}
