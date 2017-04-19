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

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/timelines/home"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Status] {
            return try decodeArray(object)
        }
    }

    /// Retrieving a local/federated timeline.
    struct GetPublicTimelineRequest: MastodonRequest {

        let isLocal: Bool

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/v1/timelines/public"
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
