//
//  MastodonRequest.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import APIKit
import Himotoki

var MastodonAPIBaseURL = URL(string: "https://mstdn.jp")!
var MastodonAPIAccessToken = ""

protocol MastodonRequest: Request {
}

extension MastodonRequest {

    var baseURL: URL {
        return MastodonAPIBaseURL
    }

    var headerFields: [String : String] {
        return [
            "Authorization": "Bearer " + MastodonAPIAccessToken
        ]
    }
}
