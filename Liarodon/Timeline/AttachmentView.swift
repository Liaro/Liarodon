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

protocol AttachmentViewDelegate: class {
    func attachmentView(_ attachmentView: AttachmentView, imageTapped imageView: UIImageView, withImageViews: [UIImageView], withAttachments attachments: [Attachment], selectedIndex index: Int)
}

class AttachmentView: UIView {

    var delegate: AttachmentViewDelegate?

    let statusImageView = StatusImageView(frame: .zero)
    var attachments: [Attachment]!
    var images: [UIImageView]!
    var gestures = [UITapGestureRecognizer]()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setAttachments(attachments: [Attachment], notSafeForWork: Bool) {
        self.addSubview(statusImageView)
        self.attachments = attachments
        statusImageView.snp.makeConstraints { $0.left.top.right.bottom.equalTo(self) }

        images = attachments.map { attachment -> UIImageView in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.kf.setImage(with: attachment.smallURL)
            imageView.isUserInteractionEnabled = true

            if notSafeForWork {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
                imageView.addSubview(label)
                label.backgroundColor = .black
                label.textAlignment = .center
                label.textColor = .white
                label.text = "NSFW"
            }

            let gesture = UITapGestureRecognizer(target: self, action: #selector(AttachmentView.imageTapped(_:)))
            imageView.addGestureRecognizer(gesture)
            return imageView
        }

        statusImageView.setImages(images: images)
    }

    func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard let senderView = gesture.view as? UIImageView else { return }

        var index = 0
        images.enumerated().forEach {
            if $0.element == senderView {
                index = $0.offset
            }
        }

        delegate?.attachmentView(self, imageTapped: senderView, withImageViews: images, withAttachments: attachments, selectedIndex: index)
    }

}
