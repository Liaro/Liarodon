//
//  Tag.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

final class Tag {

    /// The hashtag, not including the preceding #.
    public let name: String
    /// The URL of the hashtag.
    public let url: URL

    init(name: String, url: URL) {

        self.name = name
        self.url = url
    }
}

extension Tag: Decodable {

    static func decode(_ e: Extractor) throws -> Tag {

        let urlString: String = try e <| "url"
        let url = URL(string: urlString)!

        return try Tag(
            name : e <| "name",
            url  : url
        )
    }
}
