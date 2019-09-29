//
//  NSMutableAttributedStringExtension.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/1/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    convenience init(_ substrings: (String, UIFont, UIColor)...) {
        self.init()
        for (string, font, color) in substrings {
            let attributedString = NSMutableAttributedString.init(string: string, attributes: [
                .font : font,
                .foregroundColor: color
            ])
            append(attributedString)
        }
    }
}
