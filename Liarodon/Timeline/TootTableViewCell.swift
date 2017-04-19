//
//  TootTableViewCell.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/19/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit

class TootTableViewCell: UITableViewCell {

    @IBOutlet var contentTextView: UITextView! {
        didSet {
            contentTextView.textContainer.lineFragmentPadding = 0
            contentTextView.textContainerInset = .zero

        }
    }

    @IBOutlet var replyingLabel: UILabel!

    @IBOutlet var attachmentView: AttachmentView!
    @IBOutlet var attachmentHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        attachmentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        attachmentHeightConstraint.constant = 0
    }

    func configureCell(row: Int) {
        if row % 2 == 0 {
            replyingLabel.text = nil
            attachmentView.backgroundColor = UIColor.lightGray
            attachmentHeightConstraint.constant = 100
        } else {
            replyingLabel.text = "Replying to @hoge"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
