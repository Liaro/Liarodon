//
//  Relationship.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/22.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki


final class Relationship {

    /// Target account id.
    let id: Int
    /// Whether the user is currently following the account.
    let following: Bool
    /// Whether the user is currently being followed by the account.
    let followedBy: Bool
    /// Whether the user is currently blocking the account.
    let blocking: Bool
    /// Whether the user is currently muting the account.
    let muting: Bool
    /// Whether the user has requested to follow the account.
    let requested: Bool

    init(id: Int, following: Bool, followedBy: Bool, blocking: Bool, muting: Bool, requested: Bool) {

        self.id = id
        self.following = following
        self.followedBy = followedBy
        self.blocking = blocking
        self.muting = muting
        self.requested = requested
    }
}

extension Relationship: Decodable {

    static func decode(_ e: Extractor) throws -> Relationship {
        print(e)
        return try Relationship(
            id:         e <| "id",
            following:  e <| "following",
            followedBy: e <| "followed_by",
            blocking:   e <| "blocking",
            muting:     e <| "muting",
            requested:  e <| "requested"
        )
    }
}
