//
//  AccountsTableViewCell.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

final class AccountsTableViewCell: UITableViewCell {

    static var nib: UINib {
        return UINib(nibName: "AccountsTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
