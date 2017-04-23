//
//  FollowButton.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/23.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

enum FollowButtonType {
    case follow
    case unfollow
    case cancelRequest
}

class FollowButton: UIButton {

    var type: FollowButtonType = .follow {
        didSet {
            switch type {
            case .follow:
                setupAsFollow()

            case .unfollow:
                setupAsUnfollow()

            case .cancelRequest:
                setupAsCancelRequest()
            }
        }
    }

    fileprivate func setupAsFollow() {

        tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        let image = UIImage(named: "follow")!
        setImage(image, for: .normal)
        isUserInteractionEnabled = true
    }

    fileprivate func setupAsUnfollow() {

        tintColor = UIColor(red: 255/255, green: 122/255, blue: 122/255, alpha: 1)
        let image = UIImage(named: "unfollow")!
        setImage(image, for: .normal)
        isUserInteractionEnabled = true
    }

    fileprivate func setupAsCancelRequest() {

        tintColor = UIColor(red: 255/255, green: 203/255, blue: 3/255, alpha: 1)
        let image = UIImage(named: "follow")!
        setImage(image, for: .normal)
        isUserInteractionEnabled = false
    }

}
