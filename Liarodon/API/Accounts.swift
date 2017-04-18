//
//  Accounts.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki


struct GetAuthenticatedAccountRequest: MastodonRequest {

    typealias Response = Account

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/verify_credentials"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Account {
        return try Account.decodeValue(object)
    }
}

struct GetAccountRequest: MastodonRequest {

    let id: Int

    typealias Response = Account

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/" + String(id)
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Account {
        return try Account.decodeValue(object)
    }
}
