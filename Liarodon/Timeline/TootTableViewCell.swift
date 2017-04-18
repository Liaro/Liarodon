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

        }
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
