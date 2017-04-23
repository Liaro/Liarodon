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
    @IBOutlet private weak var requestedLabel: UILabel! {
        didSet {
            requestedLabel.isHidden = true
        }
    }
    @IBOutlet private weak var followUnfollowButton: UIButton!

    private enum FollowUnfollowButtonType {
        case follow
        case unfollow
        case cancelRequest
    }

    fileprivate var followUnfollowButtonType: FollowUnfollowButtonType = .follow
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
        if let relationship = relationship {
            if relationship.requested {
                changeToCancelRequestButton()
            } else if relationship.following {
                changeToUnfollowButton()
            } else {
                changeToFollowButton()
            }
            followUnfollowButton.isHidden = false
        } else {
            followUnfollowButton.isHidden = true
        }
    }

    fileprivate func changeToFollowButton() {

        followUnfollowButtonType = .follow
        followUnfollowButton.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        let image = UIImage(named: "follow")!
        followUnfollowButton.setImage(image, for: .normal)
        followUnfollowButton.isUserInteractionEnabled = true
        requestedLabel.isHidden = true
    }

    fileprivate func changeToUnfollowButton() {

        followUnfollowButtonType = .unfollow
        followUnfollowButton.tintColor = UIColor(red: 255/255, green: 122/255, blue: 122/255, alpha: 1)
        let image = UIImage(named: "unfollow")!
        followUnfollowButton.setImage(image, for: .normal)
        followUnfollowButton.isUserInteractionEnabled = true
        requestedLabel.isHidden = true
    }

    fileprivate func changeToCancelRequestButton() {

        followUnfollowButtonType = .cancelRequest
        followUnfollowButton.tintColor = lockedImageView.tintColor
        let image = UIImage(named: "follow")!
        followUnfollowButton.setImage(image, for: .normal)
        followUnfollowButton.isUserInteractionEnabled = false
        requestedLabel.isHidden = false
    }
}

// MARK: Tap follow/unfollow button
extension AccountsTableViewCell {

    @IBAction func followUnfollowButtonDidTap(_ sender: UIButton) {

        guard !isLoading else {
            return
        }

        switch followUnfollowButtonType {

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
                    s.changeToUnfollowButton()
                    s.delegate?.accountsTableViewCellDidFollow(cell: s, account: s.account)
                } else if relationship.requested {
                    s.changeToCancelRequestButton()
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
                s.changeToFollowButton()
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
