//
//  FriendViewCell.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import VisualEffectView

class FriendViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var genderDot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(with avatar: Avatar) {
        firstName.text = avatar.isFacebookFriend ? avatar.firstName : ""
        lastName.text = avatar.isFacebookFriend ? avatar.lastName : ""
        genderDot.backgroundColor = avatar.gender?.color ?? .clear
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 2
        avatar.imageData?.setup(into: imageView) { [weak imageView] result in
            if  case .value = result,
                !avatar.isFacebookFriend
            {
                imageView?.applyBlurEffect()
            } else {
                imageView?.removeBlurEffect()
            }
        }
    }
    
}

extension UIImageView {
    
    func applyBlurEffect() {
        removeBlurEffect()
        let blurView = VisualEffectView()
        blurView.blurRadius = 2
        addSubview(blurView)
        blurView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalTo(self)
        }
    }
    
    func removeBlurEffect() {
        subviews.find(VisualEffectView.self)?.removeFromSuperview()
    }
    
}
