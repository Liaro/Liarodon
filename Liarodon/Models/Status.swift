//
//  Status.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

enum Visibility: String {
    case `public`   = "public"
    case unlisted   = "unlisted"
    case `private`  = "private"
    case direct     = "direct"
}

final class Status {

    /// The ID of the status.
    let id: Int
    /// A Fediverse-unique resource ID.
    let uri: String
    /// URL to the status page (can be remote).
    let url: String
    /// The Account which posted the status.
    let account: Account
    /// nil or the ID of the status it replies to.
    let inReplyToID: Int?
    /// nil or the ID of the account it replies to.
    let inReplyToAccountID: Int?
    /// nil or the reblogged Status
    let reblog: Status?
    /// Body of the status; this will contain HTML (remote HTML already sanitized).
    let content: String
    /// The time the status was created.
    let createdAt: String
    /// The number of reblogs for the status.
    let reblogsCount: Int
    /// The number of favourites for the status.
    let favouritesCount: Int
    /// Whether the authenticated user has reblogged the status.
    let reblogged: Bool?
    /// Whether the authenticated user has favourited the status.
    let favourited: Bool?
    /// Whether media attachments should be hidden by default.
    let sensitive: Bool?
    /// If not empty, warning text that should be displayed before the actual content.
    let spoilerText: String
    /// The visibility type of the status.
    let visibility: Visibility
    /// An array of attachments.
    let mediaAttachments: [Attachment]
    /// An array of mentions.
    let mentions: [Mention]
    /// An array of tags.
    let tags: [Tag]
    /// Application from which the status was posted.
    let application: Application?

    let attributedContent: NSAttributedString

    init(id: Int, uri: String, url: String, account: Account, inReplyToID: Int?,
         inReplyToAccountID: Int?, reblog: Status?, content: String, createdAt: String,
         reblogsCount: Int, favouritesCount: Int, reblogged: Bool?, favourited: Bool?,
         sensitive: Bool?, spoilerText: String, visibility: Visibility,
         mediaAttachments: [Attachment], mentions: [Mention], tags: [Tag], application: Application?) {

        self.id = id
        self.uri = uri
        self.url = url
        self.account = account
        self.inReplyToID = inReplyToID
        self.inReplyToAccountID = inReplyToAccountID
        self.reblog = reblog
        self.content = content
        self.createdAt = createdAt
        self.reblogsCount = reblogsCount
        self.favouritesCount = favouritesCount
        self.reblogged = reblogged
        self.favourited = favourited
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.visibility = visibility
        self.mediaAttachments = mediaAttachments
        self.mentions = mentions
        self.tags = tags
        self.application = application

        let options = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue,
            ] as [String : Any]
        let html = content + "<style>p{font-size:15px}</style>"
        let text: NSAttributedString?
        if let data = html.data(using: .utf8) {
            text = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
        } else {
            text = nil
        }
        attributedContent = text! // TODO: Add plane text if text is nil
    }
}

extension Status: Decodable {

    static func decode(_ e: Extractor) throws -> Status {
        let account = try Account.decode(try e <| "account")
        let reblogE: Extractor? = try e <|? "reblog"
        let reblog = reblogE != nil ? try Status.decode(reblogE!) : nil
        let visibility = Visibility(rawValue: try e <| "visibility")!
        let mediaAttachmentsE: [Extractor] = try e <|| "media_attachments"
        let mediaAttachments: [Attachment] = try mediaAttachmentsE.map({
            try Attachment.decode($0)
        })
        let mentionsE: [Extractor] = try e <|| "mentions"
        let mentions: [Mention] = try mentionsE.map({
            try Mention.decode($0)
        })
        let tagsE: [Extractor] = try e <|| "tags"
        let tags: [Tag] = try tagsE.map({
            try Tag.decode($0)
        })
        let applicationE: Extractor? = try e <|? "application"
        let application = applicationE != nil ? try Application.decode(applicationE!) : nil

        return try Status(
            id                  : e <| "id",
            uri                 : e <| "uri",
            url                 : e <| "url",
            account             : account,
            inReplyToID         : e <|? "in_reply_to_id",
            inReplyToAccountID  : e <|? "in_reply_to_account_id",
            reblog              : reblog,
            content             : e <| "content",
            createdAt           : e <| "created_at",
            reblogsCount        : e <| "reblogs_count",
            favouritesCount     : e <| "favourites_count",
            reblogged           : e <|? "reblogged",
            favourited          : e <|? "favourited",
            sensitive           : e <|? "sensitive",
            spoilerText         : e <| "spoiler_text",
            visibility          : visibility,
            mediaAttachments    : mediaAttachments,
            mentions            : mentions,
            tags                : tags,
            application         : application
        )
    }
}


extension Status: CustomStringConvertible {

    var description: String {
        var reblogText = ""
        if let reblog = reblog {
            reblogText = "  reblog: {\n" +
                         "    id: \(reblog.id),\n" +
                         "    content: \(reblog.content), \n" +
                         "    ...\n" +
                         "  }\n"
        } else {
            reblogText = "  reblog: nil\n"
        }
        return
            "{\n" +
                "  id: \(id),\n" +
                "  content: \(content),\n" +
                "  account: {\n" +
                "    id: \(account.id),\n" +
                "    username: \(account.username), \n" +
                "    url: \(account.url), \n" +
                "    ...\n" +
                "  }\n" +
                reblogText +
                "  application: \(String(describing: application?.name)), \n" +
                "  ...\n" +
            "}"
    }
}

