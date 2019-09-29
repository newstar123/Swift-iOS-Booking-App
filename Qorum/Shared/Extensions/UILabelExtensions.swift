//
//  UILabelExtensions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/14/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit


extension UILabel {
    
    /// Whether text is truncated
    var isTextTruncated: Bool {
        guard let nsText = text as NSString? else {
            return false
        }
        let textHeight = nsText.boundingRect(with: CGSize(width: width,
                                                          height: .greatestFiniteMagnitude),
                                             options: .usesLineFragmentOrigin,
                                             attributes: [.font: font],
                                             context: nil).size.height
        return textHeight > height
    }
    
    convenience init(font: UIFont, textColor: UIColor = UIColor.white, text: String? = nil) {
        self.init()
        self.font = font
        self.textColor = textColor
        self.text = text
    }
    
    /// Adds image with given title
    ///
    /// - Parameters:
    ///   - name: image title
    ///   - behindText: image order
    func addImageWith(name: String, behindText: Bool) {
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    /// Removes image
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    /// Honestly, I have no idea what the PSD means.
    /// I just replicated the code from the demo/alpha branch implementation
    /// Anyone who know what's going on here, please, edit this doc accordingly
    ///
    /// - Parameter tracking: - no idea what it means
    func addPSD(tracking: CGFloat) {
        let text = self.text ?? ""
        let attributedString: NSMutableAttributedString
        if let attributedText = attributedText {
            attributedString = .init(attributedString: attributedText)
        } else {
            attributedString = .init(string: text)
        }
        let spacing = tracking * font.pointSize / 1000
        attributedString.addAttribute(.kern,
                                      value: spacing,
                                      range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
    
}
