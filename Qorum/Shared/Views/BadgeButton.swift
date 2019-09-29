//
//  BadgeButton.swift
//  Qorum
//
//  Created by Stanislav on 09.05.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SnapKit

class BadgeButton: UIButton {
    
    var badgeView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let badge = badgeView else { return }
            addSubview(badge)
            badge.snp.makeConstraints { make in
                make.width.height.equalTo(14)
                make.top.equalTo(2)
                make.trailing.equalTo(-2)
            }
        }
    }
    
}

class ProfileIconButton: BadgeButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        badgeView = UIImageView(image: #imageLiteral(resourceName: "VerifyMark"))
    }
    
}
