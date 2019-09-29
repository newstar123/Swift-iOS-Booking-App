//
//  MarkerContainerView.swift
//  Qorum
//
//  Created by Stanislav on 06.02.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class MarkerContainerView: UIView {
    
    /// pointing view
    let markerView = PopupView()
    
    /// marker title label
    let nameLabel = UILabel()
    
    /// marker dimensions
    var markerBodyHeight: CGFloat = 24
    var markerBodyExpandedHeight: CGFloat = 48
    var markerPadding: CGFloat = 18
    
    /// marker anchor point
    var groundAnchor: CGPoint {
        let groundAnchor = CGPoint(x: 0.5,
                                   y: 1-markerPadding/height)
        return groundAnchor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Setups marker layout
    private func setup() {
        backgroundColor = .clear
        nameLabel.textColor = .white
        nameLabel.font = UIFont.montserrat.regular(12)
        nameLabel.numberOfLines = 1
        markerView.contentView = nameLabel
        
        markerView.shapeLayer.shadowColor = UIColor.black.cgColor
        markerView.shapeLayer.shadowOpacity = 0.2
        markerView.shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
        markerView.shapeLayer.shadowRadius = 10
        markerView.shapeLayer.shouldRasterize = true
        markerView.shapeLayer.rasterizationScale = UIScreen.main.scale
        
        addSubview(markerView)
        markerView.snp.makeConstraints { maker in
            maker.height.equalTo(60)
            maker.left.equalTo(markerPadding)
            maker.bottom.right.equalTo(-markerPadding)
        }
        
        nameLabel.snp.makeConstraints { maker in
            maker.left.greaterThanOrEqualTo(10)
            maker.right.lessThanOrEqualTo(-10)
        }
        
    }
    
}


