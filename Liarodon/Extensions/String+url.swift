//
//  String+url.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/19.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import Foundation

extension String {

    var url: URL? {
        return URL(string: self)
    }
}
