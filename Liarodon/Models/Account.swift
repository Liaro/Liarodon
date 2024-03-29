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
    var followingCount: Int
    /// The number of statuses the account has made.
    let statusesCount: Int
    /// Biography of user.
    let note: String
    /// URL of the user's profile page (can be remote).
    let url: String
    /// URL to the avatar image.
    let avatar: String
    ///URL to the avatar static image (gif)
    let avatarStatic: String
    /// URL to the header image.
    let header: String
    /// URL to the header static image (gif)
    let headerStatic: String

    /// For display `note`
    let attributedNote: NSAttributedString

    init(id: Int, username: String, acct: String, displayName: String,
         locked: Bool, createdAt: String, followersCount: Int, followingCount: Int,
         statusesCount: Int, note: String, url: String, avatar: String, avatarStatic: String,
         header: String, headerStatic: String) {

        self.id = id
        self.username = username
        self.acct = acct
        self.displayName = displayName.isEmpty ? username: displayName
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

        // For display `note`
        let options: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue,
        ]
        let html = note + "<style>*{font-size:15px;text-align:center;}</style>"
        let text: NSAttributedString
        if let data = html.data(using: .utf8) {
            do {
                text = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            } catch {
                text = NSAttributedString(string: note)
            }
        } else {
            text = NSAttributedString(string: note)
        }
        attributedNote = text
    }
}

extension Account: Decodable {

    static func decode(_ e: Extractor) throws -> Account {

        let url: String = try e <| "url"
        var avatar: String = try e <| "avatar"
        var avatarStatic: String = try e <| "avatar_static"
        var header: String = try e <| "header"
        var headerStatic: String = try e <| "header_static"

        if let scheme = url.url?.scheme, let host = url.url?.host {
            let base = scheme + "://" + host

            if !avatar.contains("http") {
                avatar = base + avatar
            }
            if !avatarStatic.contains("http") {
                avatarStatic = base + avatarStatic
            }
            if !header.contains("http") {
                header = base + header
            }
            if !headerStatic.contains("http") {
                headerStatic = base + headerStatic
            }
        }

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
            url             : url,
            avatar          : avatar,
            avatarStatic    : avatarStatic,
            header          : header,
            headerStatic    : headerStatic
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
            "  locked: \(locked),\n" +
            "  createdAt: \(createdAt),\n" +
            "  followersCount: \(followersCount),\n" +
            "  followingCount: \(followingCount),\n" +
            "  statusesCount: \(statusesCount),\n" +
            "  note: \(note),\n" +
            "  url: \(url),\n" +
            "  avatar: \(avatar),\n" +
            "  avatarStatic: \(avatarStatic),\n" +
            "  header: \(header),\n" +
            "  headerStatic: \(headerStatic),\n" +
            "}"
    }
}
