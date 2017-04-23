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
