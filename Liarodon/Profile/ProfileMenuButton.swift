//
//  ProfileMenuButton.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/21.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

protocol ProfileMenuButtonDelegate: class {

    func profileMenuButtonDidTap(button: ProfileMenuButton)
}

@IBDesignable final class ProfileMenuButton: UIView {

    weak var delegate: ProfileMenuButtonDelegate?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!

    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    @IBInspectable var value: Int = 0 {
        didSet {
            valueLabel.text = "\(value)"
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {

        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed("\(type(of: self))", owner: self, options: nil)!.first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings))

    }

    @IBAction func didTap(_ sender: UIButton) {

        delegate?.profileMenuButtonDidTap(button: self)
    }
}
