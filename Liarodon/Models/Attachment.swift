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

final class Attachment {

    /// ID of the attachment.
    let id: Int
    /// Type of the attachment.
    let type: AttachmentType
    /// URL of the locally hosted version of the image.
    let url: URL
    /// For remote images, the remote URL of the original image.
    let remoteURL: URL?
    /// URL of the preview image.
    let previewURL: URL
    /// Shorter URL for the image, for insertion into text (only present on local images).
    let textURL: URL

    init(id: Int, type: AttachmentType, url: URL, remoteURL: URL?, previewURL: URL, textURL: URL) {

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

        let typeString: String = try e <| "type"
        let type = AttachmentType(rawValue: typeString)!
        let urlString: String = try e <| "url"
        let url = URL(string: urlString)!
        let remoteURLString: String? = try? e <| "remote_url"
        let remoteURL = remoteURLString != nil && remoteURLString != ""
            ? URL(string: remoteURLString!)!
            : nil
        let previewURLString: String = try e <| "preview_url"
        let previewURL = URL(string: previewURLString)!
        let textURLString: String = try e <| "text_url"
        let textURL = URL(string: textURLString)!

        return try Attachment(
            id         : e <| "id",
            type       : type,
            url        : url,
            remoteURL  : remoteURL,
            previewURL : previewURL,
            textURL    : textURL
        )
    }
}
