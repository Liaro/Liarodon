//
//  MastodonAPI+Report.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/24/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

extension MastodonAPI {

    struct AddReport: MastodonRequest {

        let accountId: Int
        let statusIds: [Int]
        let comment: String

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            return "/api/v1/reports"
        }

        var parameters: Any? {
            var params = [String: Any]()

            params["account_id"] = accountId
            params["status_ids"] = statusIds
            params["comment"] = comment

            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Void {
        }
    }
}
