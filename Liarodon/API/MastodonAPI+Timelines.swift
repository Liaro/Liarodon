//
//  MastodonAPI+Timelines.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

extension MastodonAPI {

    /// Retrieving a home timeline.
    struct GetHomeTimelineRequest: MastodonRequest {

        let maxId: Int?
        let sinceId: Int?

        init(maxId: Int? = nil, sinceId: Int? = nil) {
            self.maxId = maxId
            self.sinceId = sinceId
        }

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/timelines/home"
        }

        var parameters: Any? {
            var params = [String: Any]()

            if let maxId = maxId {
                params["max_id"] = maxId
            }
            if let sinceId = sinceId {
                params["since_id"] = sinceId
            }
            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Status] {
            return try decodeArray(object)
        }
    }

    /// Retrieving a local/federated timeline.
    struct GetPublicTimelineRequest: MastodonRequest {

        let isLocal: Bool
        let maxId: Int?
        let sinceId: Int?

        init(isLocal: Bool, maxId: Int? = nil, sinceId: Int? = nil) {
            self.isLocal = isLocal
            self.maxId = maxId
            self.sinceId = sinceId
        }

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/timelines/public"
        }

        var parameters: Any? {
            var params = [String: Any]()

            if let maxId = maxId {
                params["max_id"] = maxId
            }
            if let sinceId = sinceId {
                params["since_id"] = sinceId
            }
            if isLocal {
                params["lcoal"] = true
            }
            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Status] {
            return try decodeArray(object)
        }
    }

    /// Retrieving a tag timeline.
    struct GetTagTimelineRequest: MastodonRequest {

        let tag: String
        let isLocal: Bool

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/timelines/tag/\(tag)"
        }

        var parameters: Any? {
            if isLocal {
                return [
                    "local": true
                ]
            }
            return [:]
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Status] {
            return try decodeArray(object)
        }
    }

}
