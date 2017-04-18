//
//  Accounts.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

//  Official API document
//  https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md

import Foundation
import APIKit
import Himotoki

/// Getting the current user.
struct GetAuthenticatedAccountRequest: MastodonRequest {

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


/// Fetching an account.
struct GetAccountRequest: MastodonRequest {

    let id: Int

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/\(id)"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Account {
        return try Account.decodeValue(object)
    }
}

/// Updating the current user
// TODO: Implement


/// Getting an account's followers.
struct GetAccountFollowersRequest: MastodonRequest {

    let id: Int

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/\(id)/followers"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Account] {
        return try decodeArray(object)
    }
}

/// Getting who account is following.
struct GetAccountFollowingRequest: MastodonRequest {

    let id: Int

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/\(id)/following"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Account] {
        return try decodeArray(object)
    }
}

/// Getting an account's statuses.
struct GetAccountStatusesRequest: MastodonRequest {

    let id: Int

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/api/v1/accounts/\(id)/statuses"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Status] {
        return try decodeArray(object)
    }
}


/// Following an account.
// TODO: Implement
 
/// Unfollowing an account.
// TODO: Implement

/// Blocking an account.
// TODO: Implement

/// Unblocking an account.
// TODO: Implement

/// Muting an account.
// TODO: Implement

/// Unmuting an account.
// TODO: Implement

/// Getting an account's relationships.
// TODO: Implement

/// Searching for accounts.
// TODO: Implement
