//
//  AccessToken.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki


struct AccessToken: Decodable {

    let accessToken: String
    let createdAt: Int
    let scope: String
    let tokenType: String

    static func decode(_ e: Extractor) throws -> AccessToken {

        return try AccessToken(
            accessToken : e <| "access_token",
            createdAt   : e <| "created_at",
            scope       : e <| "scope",
            tokenType   : e <| "token_type"
        )
    }
}
