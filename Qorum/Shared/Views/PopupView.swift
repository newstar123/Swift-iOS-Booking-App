//
//  PopupView.swift
//  Qorum
//
//  Created by Stanislav on 06.02.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class PopupView: UIView {
    
    enum PointerDirection {
        case up, down
    }
    
    let shapeLayer = CAShapeLayer()
    
    var contentView: UIView? {
        willSet {
            contentView?.removeFromSuperview()
        } didSet {
            if let contentView = contentView {
                addSubview(contentView)
            }
        }
    }
    
    /// popup label height
    var bodyHeight: CGFloat = 24
    
    /// popup label container corner radius
    var bodyCornerRadius: CGFloat = 12
    
    /// arrow direction
    var pointerDirection = PointerDirection.down
    
    /// arrow pointer size
    var pointerSize: CGSize = CGSize(width: 12, height: 12)

    /// contining rectangular for body view
    var bodyRect: CGRect {
        let y = pointerDirection == .down ? height-bodyHeight-pointerSize.height+2 : pointerSize.height-2
        return CGRect(x: 0, y: y, width: bounds.width, height: bodyHeight)
    }
    
    /// containing rectangular for pointer
    var pointerRect: CGRect {
        let y = pointerDirection == .down ? height-pointerSize.height : 0
        return CGRect(origin: CGPoint(x: (bounds.width-pointerSize.width)/2, y: y),
                      size: pointerSize)
    }
    
    /// path do draw body view with circled angles
    var bodyPath: UIBezierPath {
        return UIBezierPath(roundedRect: bodyRect, cornerRadius: bodyCornerRadius)
    }
    
    /// path to draw arrow down pointer
    var pointerPath: UIBezierPath {
        let pointerPath = UIBezierPath()
        switch pointerDirection {
        case .up:
            pointerPath.move(to: CGPoint(x: pointerRect.minX, y: pointerRect.maxY))
            pointerPath.addLine(to: CGPoint(x: pointerRect.midX, y: pointerRect.minY))
            pointerPath.addLine(to: CGPoint(x: pointerRect.maxX, y: pointerRect.maxY))
        case .down:
            pointerPath.move(to: CGPoint(x: pointerRect.minX, y: pointerRect.minY))
            pointerPath.addLine(to: CGPoint(x: pointerRect.maxX, y: pointerRect.minY))
            pointerPath.addLine(to: CGPoint(x: pointerRect.midX, y: pointerRect.maxY))
        }
        pointerPath.close()
        return pointerPath
    }
    
    /// path with all parts added
    var mainPath: UIBezierPath {
        let mainPath = UIBezierPath()
        mainPath.append(bodyPath)
        mainPath.append(pointerPath)
        return mainPath
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = mainPath.cgPath
        contentView?.center = CGPoint(x: bounds.width/2,
                                      y: bodyRect.origin.y + bodyRect.height/2)
    }
    
}


