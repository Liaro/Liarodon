//
//  Attachment.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation
import Himotoki

enum AttachmentType: String {
    case image  = "image"
    case video  = "video"
    case gifv   = "gifv"
}

extension String {
    var notMissingURL: URL? {
        if self.contains("http") {
            return self.url
        } else {
            return nil
        }
    }
}

final class Attachment {

    /// ID of the attachment.
    let id: Int
    /// Type of the attachment.
    let type: AttachmentType
    /// URL of the locally hosted version of the image.
    let url: String
    /// For remote images, the remote URL of the original image.
    let remoteURL: String?
    /// URL of the preview image.
    let previewURL: String
    /// Shorter URL for the image, for insertion into text (only present on local images).
    let textURL: String?

    var mainURL: URL? {
        return url.notMissingURL ?? remoteURL?.notMissingURL ?? previewURL.notMissingURL
    }

    var smallURL: URL? {
        return previewURL.notMissingURL ?? remoteURL?.notMissingURL ?? url.notMissingURL
    }

    init(id: Int, type: AttachmentType, url: String, remoteURL: String?, previewURL: String, textURL: String?) {

        self.id = id
        self.type = type
        self.url = url
        self.remoteURL = remoteURL
        self.previewURL = previewURL
        self.textURL = textURL
    }
}

extension Attachment: Decodable {

    static func decode(_ e: Extractor) throws -> Attachment {

        return try Attachment(
            id         : e <| "id",
            type       : AttachmentType(rawValue: e <| "type")!,
            url        : e <| "url",
            remoteURL  : e <|? "remote_url",
            previewURL : e <| "preview_url",
            textURL    : e <|? "text_url"
        )
    }
}
