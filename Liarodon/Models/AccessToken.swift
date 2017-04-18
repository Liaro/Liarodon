//
//  AccessToken.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

struct PostAccessTokenRequest: MastodonRequest {

    let clientID: String
    let clientSecret: String
    let username: String        // User mail address
    let password: String

    typealias Response = AccessToken

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/oauth/token"
    }

    var headerFields: [String : String] {
        return [:]
    }

    var parameters: Any? {
        return [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "password",
            "username": username,
            "password": password
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> AccessToken {
        return try AccessToken.decodeValue(object)
    }
}

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
