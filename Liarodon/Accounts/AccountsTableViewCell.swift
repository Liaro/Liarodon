//
//  AccountsTableViewCell.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import Kingfisher
import APIKit


protocol AccountsTableViewCellDelegate: class {

    func accountsTableViewCellDidFollow(cell: AccountsTableViewCell, account: Account)
    func accountsTableViewCellDidUnfollow(cell: AccountsTableViewCell, account: Account)
}

final class AccountsTableViewCell: UITableViewCell {

    static var nib: UINib {
        return UINib(nibName: "AccountsTableViewCell", bundle: nil)
    }

    weak var delegate: AccountsTableViewCellDelegate?

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var displayNameLabel: UILabel! {
        didSet {
            displayNameLabel.text = ""
        }
    }
    @IBOutlet private weak var acctLabel: UILabel! {
        didSet {
            acctLabel.text = ""
        }
    }
    @IBOutlet private weak var lockedImageView: UIImageView! {
        didSet {
            lockedImageView.isHidden = true
            // hack: Enable UIImageView tint color
            let image = lockedImageView.image!.withRenderingMode(.alwaysTemplate)
            lockedImageView.image = nil
            lockedImageView.image = image
        }
    }
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet private weak var requestedLabel: UILabel! {
        didSet {
            requestedLabel.isHidden = true
        }
    }

    fileprivate(set) var account: Account!
    fileprivate var relationship: Relationship?
    fileprivate var isLoading = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func configureCell(account: Account) {

        self.account = account
        avatarImageView.kf.setImage(with: account.avatar.url)
        displayNameLabel.text = account.displayName
        acctLabel.text = "@" + account.acct
        lockedImageView.isHidden = !account.locked
    }

    /// For followers accounts
    func configureCell(follower account: Account, relationship: Relationship? = nil) {

        configureCell(account: account)

        requestedLabel.isHidden = true

        if let relationship = relationship {
            if relationship.requested {
                followButton.type = .cancelRequest
                requestedLabel.isHidden = false
            } else if relationship.following {
                followButton.type = .unfollow
            } else {
                followButton.type = .follow
            }
            followButton.isHidden = false
        } else {
            followButton.isHidden = true
        }
    }
}

// MARK: Tap follow/unfollow button
extension AccountsTableViewCell {

    @IBAction func followButtonDidTap(_ sender: FollowButton) {

        guard !isLoading else {
            return
        }

        switch sender.type {

        case .follow:
            follow()

        case .unfollow:
            unfollow()

        case .cancelRequest:
            // TODO: Follow request senders cannot cancel?
            // I tried POST unfollow, but relationship.requested was 1.
            // I don't know how cancel.
            break
        }
    }

    private func follow() {

        isLoading = true

        let request = MastodonAPI.PostAccountFollowRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success(let relationship):
                if relationship.following {
                    s.followButton.type = .unfollow
                    s.delegate?.accountsTableViewCellDidFollow(cell: s, account: s.account)
                } else if relationship.requested {
                    s.followButton.type = .cancelRequest
                }

            case .failure(let error):
                print(error)
            }

            s.isLoading = false
        }
    }

    private func unfollow(isCancelRequest: Bool = false) {

        isLoading = true

        let request = MastodonAPI.PostAccountUnfollowRequest(id: account.id)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {

            case .success( _):
                s.followButton.type = .follow
                if !isCancelRequest {
                    s.delegate?.accountsTableViewCellDidUnfollow(cell: s, account: s.account)
                }

            case .failure(let error):
                print(error)
            }

            s.isLoading = false
        }
    }
}
