//
//  MastodonAPI+Accounts.swift
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

extension MastodonAPI {

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


    /// Extract sinceID and maxID from urlResponse.allHeaderFields["Link"].
    /// For GetAccountFollowersRequest/GetAccountFollowingRequest below.
    // Link formart example (string)
    // <https://friends.nico/api/v1/accounts/512/following?limit=80&max_id=211174>; rel="next", <https://friends.nico/api/v1/accounts/512/following?limit=80&since_id=201174>; rel="prev"
    //
    private static func extractSinceIDMaxID(raw: String) -> (sinceID: Int?, maxID: Int?) {
        var sinceID: Int?
        var maxID: Int?
        let linkStrings = raw.components(separatedBy: ",")
        for link in linkStrings {
            guard let end = link.range(of: ">;") else { continue }
            if let since = link.range(of: "since_id=") {
                let substring = link.substring(with: since.upperBound..<end.lowerBound)
                sinceID = Int(substring)
            }
            else if let max = link.range(of: "max_id=") {
                let substring = link.substring(with: max.upperBound..<end.lowerBound)
                maxID = Int(substring)
            }
        }
        return (sinceID: sinceID, maxID: maxID)
    }

    /// Getting an account's followers.
    struct GetAccountFollowersRequest: MastodonRequest {

        let id: Int
        let maxID: Int?
        let sinceID: Int?
        let limit: Int?

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/accounts/\(id)/followers"
        }

        var parameters: Any? {
            var params = [String: Any]()
            if let maxID = maxID {
                params["max_id"] = maxID
            }
            if let sinceID = sinceID {
                params["since_id"] = sinceID
            }
            if let limit = limit {
                params["limit"] = limit
            }
            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> (accounts: [Account], sinceID: Int?, maxID: Int?) {
            var sinceID: Int?
            var maxID: Int?
            if let linkValue = urlResponse.allHeaderFields["Link"] as? String {
                (sinceID, maxID) = MastodonAPI.extractSinceIDMaxID(raw: linkValue)
            }
            return (try decodeArray(object), sinceID, maxID)
        }
    }

    /// Getting who account is following.
    struct GetAccountFollowingRequest: MastodonRequest {

        let id: Int
        let maxID: Int?
        let sinceID: Int?
        let limit: Int?

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/accounts/\(id)/following"
        }

        var parameters: Any? {
            var params = [String: Any]()
            if let maxID = maxID {
                params["max_id"] = maxID
            }
            if let sinceID = sinceID {
                params["since_id"] = sinceID
            }
            if let limit = limit {
                params["limit"] = limit
            }
            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> (accounts: [Account], sinceID: Int?, maxID: Int?) {
            var sinceID: Int?
            var maxID: Int?
            if let linkValue = urlResponse.allHeaderFields["Link"] as? String {
                (sinceID, maxID) = MastodonAPI.extractSinceIDMaxID(raw: linkValue)
            }
            return (try decodeArray(object), sinceID, maxID)
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
    struct PostAccountFollowRequest: MastodonRequest {

        static let notificationName = NSNotification.Name(rawValue: "PostAccountFollowRequestNofication")

        let id: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/accounts/\(id)/follow"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Relationship {

            let relationship = try Relationship.decodeValue(object)

            DispatchQueue.main.async {
                let notification = Notification(
                    name: PostAccountFollowRequest.notificationName,
                    object: self,
                    userInfo: ["relationship": relationship])
                NotificationCenter.default.post(notification)
            }

            return relationship
        }
    }

    /// Unfollowing an account.
    struct PostAccountUnfollowRequest: MastodonRequest {

        static let notificationName = NSNotification.Name(rawValue: "PostAccountUnfollowRequestNofication")

        let id: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/accounts/\(id)/unfollow"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Relationship {

            let relationship = try Relationship.decodeValue(object)

            DispatchQueue.main.async {
                let notification = Notification(
                    name: PostAccountUnfollowRequest.notificationName,
                    object: self,
                    userInfo: ["relationship": relationship])
                NotificationCenter.default.post(notification)
            }

            return relationship
        }
    }

    /// Blocking an account.
    struct PostAccountBlockRequest: MastodonRequest {

        let id: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/accounts/\(id)/block"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Relationship {

            let relationship = try Relationship.decodeValue(object)
            return relationship
        }
    }

    /// Unblocking an account.
    struct PostAccountUnblockRequest: MastodonRequest {

        let id: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/accounts/\(id)/unblock"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Relationship {

            let relationship = try Relationship.decodeValue(object)
            return relationship
        }
    }

    /// Muting an account.
    // TODO: Implement

    /// Unmuting an account.
    // TODO: Implement

    /// Getting an account's relationships.
    struct GetAccountRelationshipsRequest: MastodonRequest, QueryParameters {

        let ids: [Int]

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/accounts/relationships"
        }

        func encode() -> String? {
            return "id%5B%5D=" + ids.map({"\($0)"}).joined(separator: "&id%5B%5D=")
        }

        var queryParameters: QueryParameters? {
            return self
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Relationship] {
            return try decodeArray(object)
        }
    }

    /// Searching for accounts.
    // TODO: Implement
}
