//
//  MastodonAPI.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import APIKit

final class MastodonAPI {

    static var instanceURL: URL!
    static var accessToken: String!
}

protocol MastodonRequest: JSONRequest {
}

extension MastodonRequest {

    var baseURL: URL {
        return MastodonAPI.instanceURL
    }

    var headerFields: [String : String] {
        return [
            "Authorization": "Bearer " + MastodonAPI.accessToken
        ]
    }
}
