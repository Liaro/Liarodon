//
//  TootTableViewCell.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/19/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import Kingfisher

class TootTableViewCell: UITableViewCell {

    @IBOutlet var contentTextView: UITextView! {
        didSet {
            contentTextView.textContainer.lineFragmentPadding = 0
            contentTextView.textContainerInset = .zero
        }
    }

    @IBOutlet var replyingLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var statusReblogLabel: UILabel!

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var attachmentView: AttachmentView!
    @IBOutlet var attachmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var attachmentViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            attachmentViewBottomConstraint.constant = 0
        }
    }

    @IBOutlet var boostButton: UIButton!
    @IBOutlet var favouriteButton: UIButton!

    @IBOutlet var moreButton: UIButton!
    @IBOutlet var replyButton: UIButton!
    var status: Status!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        attachmentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        attachmentHeightConstraint.constant = 0
        attachmentViewBottomConstraint.constant = 0
    }

    func configureCell(status targetStatus: Status) {
        // If status has a reblog, show a boosted status mainly.
        self.status = targetStatus.reblog ?? targetStatus

        if let _ = targetStatus.reblog {
            statusReblogLabel.text = "\(targetStatus.account.username) boosted"
        } else {
            statusReblogLabel.text = nil
        }

        if let replyAccountID = status.inReplyToAccountID {
            replyingLabel.text = "Replying to \(replyAccountID)"
        } else {
            replyingLabel.text = nil
        }

        let options = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue,
            NSFontAttributeName: UIFont.systemFont(ofSize: 100)
        ] as [String : Any]
        let html = status.content + "<style>p{font-size:15px}</style>"
        let text: NSAttributedString?
        if let data = html.data(using: .utf8) {
            text = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
        } else {
            text = nil
        }

        contentTextView.attributedText = text!

        avatarImageView.kf.setImage(with: status.account.avatar.url)
        displayNameLabel.text = status.account.displayName
        usernameLabel.text = "@\(status.account.username)"

        if !status.mediaAttachments.isEmpty {
            attachmentView.backgroundColor = UIColor.lightGray
            attachmentHeightConstraint.constant = 100
            attachmentViewBottomConstraint.constant = 15
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    @IBAction func replyButtonTapped(_ sender: UIButton) {
    }
    @IBAction func reblogButtonTapped(_ sender: UIButton) {
    }

    @IBAction func favouriteButtonTapped(_ sender: UIButton) {
    }
    @IBAction func moreButtonTapped(_ sender: UIButton) {
    }
}


