//
//  NSTextAttachmentExtension.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/6/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

extension NSTextAttachment {
    
    convenience init(image: UIImage, aligningFont font: UIFont? = .none) {
        self.init()
        self.image = image
        if let font = font {
            let mid = font.descender + font.capHeight
            bounds = CGRect(x: 0, y: font.descender - image.size.height / 2 + mid + 2, width: image.size.width, height: image.size.height).integral
        }
    }
}
