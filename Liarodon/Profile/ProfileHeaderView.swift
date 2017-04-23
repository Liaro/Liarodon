//
//  ProfileHeaderView.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

final class ProfileHeaderView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        switch view {

        case let button as UIButton:
            return button

        case let textView as LinkTextView:
            return textView

        default:
            break
        }
        return nil
    }
}
