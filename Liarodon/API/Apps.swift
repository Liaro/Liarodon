//
//  Apps.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki


struct PostAppsRequest: MastodonRequest {

    let clientName: String

    typealias Response = App

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/api/v1/apps"
    }

    var parameters: Any? {
        return [
            "client_name": clientName,
            "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
            "scopes": "read%20write%20follow"
        ]
    }

    var headerFields: [String : String] {
        return [:]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> App {
        return try App.decodeValue(object)
    }
}
