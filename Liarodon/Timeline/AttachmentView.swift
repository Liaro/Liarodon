//
//  AttachmentView.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/19/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class AttachmentView: UIView {

    let statusImageView = StatusImageView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setAttachments(attachments: [Attachment]) {
        self.addSubview(statusImageView)
        statusImageView.snp.makeConstraints { $0.left.top.right.bottom.equalTo(self) }

        let images = attachments.map { attachment -> UIImageView in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.kf.setImage(with: attachment.previewURL.url)
            return imageView
        }

        statusImageView.setImages(images: images)
    }

}
