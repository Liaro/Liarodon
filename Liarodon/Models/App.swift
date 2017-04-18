//
//  App.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

final class App {

    let id: Int
    let clientID: String
    let clientSecret: String
    let redirectURI: String

    init(id: Int, clientID: String, clientSecret: String, redirectURI: String) {

        self.id = id
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
    }
}

extension App: Decodable {

    static func decode(_ e: Extractor) throws -> App {

        return try App(
            id              : e <| "id",
            clientID        : e <| "client_id",
            clientSecret    : e <| "client_secret",
            redirectURI     : e <| "redirect_uri"
        )
    }
}
