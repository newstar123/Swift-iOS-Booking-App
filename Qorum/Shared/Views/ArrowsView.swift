//
//  ArrowsView.swift
//  Qorum
//
//  Created by Stanislav on 25.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class ArrowsView: UIView {
    
    @IBInspectable var arrowsCount: Int = 3
    @IBInspectable var arrowSize: CGSize = CGSize(width: 40, height: 24)
    @IBInspectable var arrowSpacing: CGFloat = 16
    @IBInspectable var animationDuration: Double = 1
    
    private let animationKey = "loading"
    
    /// layers array for arrows
    private lazy var arrowLayers: [CAShapeLayer] = {
        var layers: [CAShapeLayer] = []
        for index in 0..<arrowsCount {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: arrowSize.height))
            path.addLine(to: CGPoint(x: arrowSize.width/2, y: 0))
            path.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height))
            let arrowLayer = CAShapeLayer()
            arrowLayer.lineCap = kCALineJoinRound
            arrowLayer.lineJoin = kCALineJoinRound
            arrowLayer.lineWidth = 3
            arrowLayer.fillColor = nil
            arrowLayer.strokeColor = UIColor.white.cgColor
            arrowLayer.path = path.cgPath
            layers.append(arrowLayer)
        }
        return layers
    }()
    
    /* An array of `NSNumber' objects defining the pacing of the
     * animation. Each time corresponds to one value in the `values' array,
     * and defines when the value should be used in the animation function.
     * Each value in the array is a floating point number in the range
     * [0,1]. */
    private lazy var arrowKeyTimes: [NSNumber] = {
        let initial = 1/Float(arrowsCount+2)
        var times: [NSNumber] = [NSNumber(value: initial)]
        for index in 0...arrowsCount {
            let time = Double(index+1)/Double(arrowsCount+1)
            times.append(NSNumber(value: time))
        }
        return times
    }()
    
    /// Animation set for arrows
    private lazy var arrowAnimations: [CAKeyframeAnimation] = {
        var animations: [CAKeyframeAnimation] = []
        for index in 0..<arrowsCount {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = animationValues(for: index, of: arrowsCount)
            animation.keyTimes = arrowKeyTimes
            animation.duration = animationDuration
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            animations.append(animation)
        }
        return animations
    }()
    
    init(frame: CGRect = .zero,
         arrowsCount: Int = 3,
         arrowSize: CGSize = CGSize(width: 40, height: 24),
         arrowSpacing: CGFloat = 16,
         animationDuration: TimeInterval = 1)
    {
        self.arrowsCount = arrowsCount
        self.arrowSize = arrowSize
        self.arrowSpacing = arrowSpacing
        self.animationDuration = animationDuration
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        for (arrow, animation) in zip(arrowLayers, arrowAnimations) {
            arrow.add(animation, forKey: animationKey)
            layer.addSublayer(arrow)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, arrowLayer) in arrowLayers.enumerated() {
            let rect = CGRect(x: (bounds.width-arrowSize.width)/2,
                              y: (bounds.height-arrowSize.height)/2,
                              width: arrowSize.width,
                              height: arrowSize.height)
            let yOffset = CGFloat(index-arrowsCount/2) * arrowSpacing
            arrowLayer.frame = rect.offsetBy(dx: 0, dy: yOffset)
        }
    }
    
    private func animationValues(for index: Int, of count: Int) -> [NSNumber] {
        var values: [NSNumber] = [0]
        for element in 0..<count {
            var value = 2 - Float(element+index) / Float(count-1)
            switch value {
            case ...0: value = 1/Float(count)
            case 0...1: break
            default: value = 0
            }
            values.append(NSNumber(value: value))
        }
        return values + [0]
    }
    
    /// Shows arrow with animation
    func show() {
        for (arrow, animation) in zip(arrowLayers, arrowAnimations)
            where arrow.animation(forKey: animationKey) == nil
        {
            arrow.add(animation, forKey: animationKey)
        }
        isHidden = false
    }
    
    /// Hides arrows
    func hide() {
        isHidden = true
        for layer in arrowLayers {
            layer.removeAllAnimations()
        }
    }
    
}
