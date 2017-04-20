//
//  StatusImageView.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/21/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class StatusImageView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var images = [UIImageView]()
    var mainStackView = UIStackView(frame: .zero)
    var substackViews = [UIStackView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(mainStackView)
        mainStackView.snp.makeConstraints { $0.left.top.right.bottom.equalTo(self) }

        mainStackView.distribution = .fillEqually
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.spacing = 2

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // It may be buggy and too slow...
        // Fix it!
        mainStackView.subviews.forEach {
            if let childStackView = $0 as? UIStackView {
                childStackView.subviews.forEach {
                    childStackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
            }
            substackViews = []
            mainStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if traitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass: .regular)) {
            // side by side in a row
            // ****
            images.forEach {
                mainStackView.addArrangedSubview($0)
            }
        } else {
            // square
            // **
            // **
            var subStackView: UIStackView!
            images.enumerated().forEach {
                if $0.offset <= 1 {
                    subStackView = UIStackView(frame: .zero)
                    subStackView.distribution = .fillEqually
                    subStackView.axis = .vertical
                    subStackView.spacing = 2
                    mainStackView.addArrangedSubview(subStackView)
                    substackViews.append(subStackView)
                }

                if $0.offset == 0 || $0.offset == 3 {
                    substackViews[0].addArrangedSubview($0.element)
                } else {
                    substackViews[1].addArrangedSubview($0.element)
                }

            }
        }
    }

    func setImages(images: [UIImageView]) {
        self.images = images
        setNeedsLayout()
        layoutIfNeeded()
    }

}
