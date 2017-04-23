//
//  MastodonAPI+Status.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

extension MastodonAPI {

    struct AddMedia: MastodonRequest {

        let imageData: Data

        var bodyParameters: BodyParameters? {
            return MultipartFormDataBodyParameters(parts: [MultipartFormDataBodyParameters.Part(data: imageData, name: "file", mimeType: "image/jpeg", fileName: "file")])
        }

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/media"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Attachment {
            return try decodeValue(object)
        }
    }


    struct AddStatus: MastodonRequest {
        let status: String
        let inReplyToId: Int?
        let mediaIds: [Int]
        let sensitive: Bool
        let spoilerText: String?
        let visibility: Visibility

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/statuses"
        }

        var parameters: Any? {
            var params = [String: Any]()

            params["status"] = self.status
            if let inReplyToId = self.inReplyToId {
                params["in_reply_to_id"] = inReplyToId
            }
            if !self.mediaIds.isEmpty {
                params["media_ids"] = self.mediaIds
            }
            if self.sensitive {
                params["sensitive"] = true
            }
            if let spoilerText = self.spoilerText {
                params["spoiler_text"] = spoilerText
            }
            params["visibility"] = visibility.rawValue

            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Status {
            return try decodeValue(object)
        }

    }

    struct AddReblogToStatus: MastodonRequest {

        let statusId: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/statuses/\(statusId)/reblog"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Status {
            return try decodeValue(object)
        }
    }


    struct RemoveReblogToStatus: MastodonRequest {

        let statusId: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/statuses/\(statusId)/unreblog"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Status {
            return try decodeValue(object)
        }
    }

    struct AddFavouriteToStatus: MastodonRequest {

        let statusId: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/statuses/\(statusId)/favourite"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Status {
            return try decodeValue(object)
        }
    }


    struct RemoveFavouriteToStatus: MastodonRequest {

        let statusId: Int

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/statuses/\(statusId)/unfavourite"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Status {
            return try decodeValue(object)
        }
    }
}
