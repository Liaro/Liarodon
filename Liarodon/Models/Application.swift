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
    public let website: URL?

    init(name: String, website: URL?) {

        self.name = name
        self.website = website
    }
}

extension Application: Decodable {

    static func decode(_ e: Extractor) throws -> Application {
        let urlString: String? = try? e <| "website"
        let url = urlString != nil ? URL(string: urlString!)! : nil

        return try Application(
            name    : e <| "name",
            website : url
        )
    }
}
