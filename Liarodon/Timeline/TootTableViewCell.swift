//
//  TootTableViewCell.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/19/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import Kingfisher
import DateToolsSwift
import APIKit

enum StatusLink {
    case tag(Tag)
    case mention(Mention)
    case attachment(Attachment, Int)
    case link(URL)
}

protocol TootTableViewCellDelegate: class {
    func tootTableViewCell(_ cell: TootTableViewCell, shouldMoveTo link: StatusLink)
    func tootTableViewCellMoreButtonTapped(_ cell: TootTableViewCell)
}

class TootTableViewCell: UITableViewCell {

    weak var delegate: TootTableViewCellDelegate?

    @IBOutlet var contentTextView: UITextView! {
        didSet {
            contentTextView.textContainer.lineFragmentPadding = 0
            contentTextView.textContainerInset = .zero
            contentTextView.delegate = self
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
    @IBOutlet var contentBottomMarginConstraint: NSLayoutConstraint!

    @IBOutlet var boostButton: UIButton!
    @IBOutlet var favouriteButton: UIButton!

    @IBOutlet var moreButton: UIButton!
    @IBOutlet var replyButton: UIButton!
    var status: Status!

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = 4
        avatarImageView.layer.masksToBounds = true

        attachmentView.layer.cornerRadius = 4
        attachmentView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        attachmentView.subviews.forEach {
            $0.removeFromSuperview()
        }

        attachmentHeightConstraint.constant = 0
        attachmentViewBottomConstraint.constant = 0
        contentBottomMarginConstraint.constant = -25.5
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

        if status.cwOpened {
            contentTextView.attributedText = status.attributedContentIncludingCW
        } else {
            contentTextView.attributedText = status.attributedContent
        }

        avatarImageView.kf.setImage(with: status.account.avatar.url)
        displayNameLabel.text = status.account.displayName
        usernameLabel.text = "@\(status.account.acct)"

        let date = Date(dateString: status.createdAt, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone(secondsFromGMT: 0)!)
        timeLabel.text = date.shortTimeAgoSinceNow

        if !status.mediaAttachments.isEmpty {
            attachmentView.backgroundColor = UIColor.lightGray
            attachmentHeightConstraint.constant = 130
            attachmentViewBottomConstraint.constant = 15
            attachmentView.setAttachments(attachments: status.mediaAttachments, notSafeForWork: status.sensitive)
        }
        if !status.shouldHasLessMargin {
            contentBottomMarginConstraint.constant = 8
        }
        configureButtons()
    }

    private func configureButtons() {
        if status.favourited == true {
            favouriteButton.tintColor = UIColor.blue
        } else {
            favouriteButton.tintColor = UIColor.gray
        }
        if status.reblogged == true {
            boostButton.tintColor = UIColor.blue
        } else {
            boostButton.tintColor = UIColor.gray
        }
        moreButton.tintColor = .gray
        replyButton.tintColor = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    @IBAction func replyButtonTapped(_ sender: UIButton) {
        // FIXME: The reply button's userInteractionEnabled is false for now
        // because the result on tap this button is same to tap cell.
        // If you change this result or refector, you have to enable checkbox on storyboard file.
        // That's why, this method is empty.
    }
    @IBAction func reblogButtonTapped(_ sender: UIButton) {
        status.reblogged = !status.reblogged
        configureButtons()
        if status.reblogged {
            let request = MastodonAPI.AddReblogToStatus(statusId: status.id)
            Session.send(request) { (result) in
                switch result {
                case .success(let status):
                    print(status)
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let request = MastodonAPI.RemoveReblogToStatus(statusId: status.id)
            Session.send(request) { (result) in
                switch result {
                case .success(let status):
                    print(status)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    @IBAction func favouriteButtonTapped(_ sender: UIButton) {
        status.favourited = !status.favourited
        configureButtons()
        if status.favourited {
            let request = MastodonAPI.AddFavouriteToStatus(statusId: status.id)
            Session.send(request) { (result) in
                switch result {
                case .success(let status):
                    print(status)
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let request = MastodonAPI.RemoveFavouriteToStatus(statusId: status.id)
            Session.send(request) { (result) in
                switch result {
                case .success(let status):
                    print(status)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        delegate?.tootTableViewCellMoreButtonTapped(self)
    }
}

extension TootTableViewCell: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        // for iOS9
        if #available(iOS 10.0, *) {
        } else {
            interact(withURL: URL)
        }
        return false
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction != .invokeDefaultAction {
            // Prevent 3D Touch actions: http://stackoverflow.com/questions/40090138/shouldinteractwithurl-called-twice-on-3d-touch
            return false
        }

        interact(withURL: URL)

        return false
    }

    private func interact(withURL URL: URL) {
        if URL.absoluteString == "app://read/more" {
            // the url added at my status model
            status.cwOpened = true
            contentTextView.attributedText = status.attributedContentIncludingCW
            setNeedsLayout()
            superview?.layoutIfNeeded()
            superview?.superview?.setNeedsLayout()
            superview?.superview?.layoutIfNeeded()
            (superview?.superview as? UITableView)?.reloadData()
            return
        }

        let matchedTag = status.tags.filter {
            if $0.url == URL.absoluteString {
                return true
            }
            return false
        }.first
        let matchedMention = status.mentions.filter {
            if $0.url == URL.absoluteString {
                return true
            }
            return false
        }.first
        let matchedAttachment = status.mediaAttachments.enumerated().filter {
            if $0.element.url == URL.absoluteString || $0.element.remoteURL == URL.absoluteString {
                return true
            }
            return false
        }.first

        if let tag = matchedTag {
            delegate?.tootTableViewCell(self, shouldMoveTo: .tag(tag))
        } else if let mention = matchedMention {
            delegate?.tootTableViewCell(self, shouldMoveTo: .mention(mention))
        } else if let attachment = matchedAttachment {
            delegate?.tootTableViewCell(self, shouldMoveTo: .attachment(attachment.element, attachment.offset))
        } else {
            delegate?.tootTableViewCell(self, shouldMoveTo: .link(URL))
        }
    }
}
