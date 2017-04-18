//
//  Mention.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

final class Mention {

    /// URL of user's profile (can be remote).
    let url: URL
    /// The username of the account.
    let username: String
    /// Equals username for local users, includes @domain for remote ones.
    let acct: String
    /// Account ID.
    let id: Int

    init(url: URL, username: String, acct: String, id: Int) {

        self.url = url
        self.username = username
        self.acct = acct
        self.id = id
    }
}

extension Mention: Decodable {

    static func decode(_ e: Extractor) throws -> Mention {

        let urlString: String = try e <| "url"
        let url = URL(string: urlString)!

        return try Mention(
            url      : url,
            username : e <| "username",
            acct     : e <| "acct",
            id       : e <| "id"
        )
    }
}
