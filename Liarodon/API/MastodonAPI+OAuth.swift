//
//  MastodonAPI+OAuth.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

extension MastodonAPI {

    struct PostAccessTokenRequest: MastodonRequest {

        let clientID: String
        let clientSecret: String
        let username: String        // User mail address
        let password: String

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/oauth/token"
        }

        var parameters: Any? {
            return [
                "client_id": clientID,
                "client_secret": clientSecret,
                "grant_type": "password",
                "username": username,
                "password": password,
                "scope": "read write follow"
            ]
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> AccessToken {
            return try AccessToken.decodeValue(object)
        }
    }
}
