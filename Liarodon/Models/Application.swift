//
//  Application.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

final class Application {

    /// Name of the app.
    public let name: String
    /// Homepage URL of the app.
    public let website: String?

    init(name: String, website: String?) {

        self.name = name
        self.website = website
    }
}

extension Application: Decodable {

    static func decode(_ e: Extractor) throws -> Application {

        return try Application(
            name    : e <| "name",
            website : e <|? "website"
        )
    }
}
