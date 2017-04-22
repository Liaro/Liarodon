//
//  AccountsTableViewCell.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import Kingfisher


final class AccountsTableViewCell: UITableViewCell {

    static var nib: UINib {
        return UINib(nibName: "AccountsTableViewCell", bundle: nil)
    }
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var acctLabel: UILabel!
    @IBOutlet weak var followUnfollowButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(account: Account, followed: Bool? = nil) {

        avatarImageView.kf.setImage(with: account.avatar.url)
        displayNameLabel.text = account.displayName
        acctLabel.text = "@" + account.acct
        
        if let followed = followed {
            let imageName: String
            if followed {
                imageName = "unfollow"
                followUnfollowButton.tintColor = UIColor(red: 255/255, green: 122/255, blue: 122/255, alpha: 1)
            } else {
                imageName = "follow"
                followUnfollowButton.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
            }
            let image = UIImage(named: imageName)!
            followUnfollowButton.setImage(image, for: .normal)
            followUnfollowButton.isHidden = false
        } else {
            followUnfollowButton.isHidden = true
        }
    }
    
}
