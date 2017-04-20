//
//  LinkTextView.swift
//  Liarodon
//
//  Created by 斉藤　洸紀　 on 2017/04/20.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit

class LinkTextView : UITextView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var p = point
        p.y = p.y - self.textContainerInset.top
        p.x = p.x - self.textContainerInset.left

        let i = self.layoutManager.characterIndex(for: p, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let attr = self.textStorage.attributes(at: i, effectiveRange: nil)

        var touchingLink = false
        if attr[NSLinkAttributeName] != nil {
            let glyphIndex = self.layoutManager.glyphIndexForCharacter(at: i)
            self.layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(glyphIndex, 1), using: { (recr, usedRect, container, glyphRange, stop) -> Void in
                if usedRect.contains(p) {
                    touchingLink = true
                    stop.initialize(to: true)
                }
            })
            return (touchingLink) ? self : nil
        }
        return nil
    }
}
