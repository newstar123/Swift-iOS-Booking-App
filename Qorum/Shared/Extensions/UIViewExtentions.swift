//
//  UIViewExtentions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/24/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import VisualEffectView

extension UIView {
    
    /// Returns all subviews recursivery
    var allSubviews: [UIView] {
        var array: [UIView] = []
        for subview in subviews {
            array.append(subview)
            array += subview.allSubviews
        }
        return array
    }
    
    /// Returns blurred background
    ///
    /// - Returns: blurred view
    static func blurredBackground() -> VisualEffectView {
        let blurView = VisualEffectView()
        blurView.blurRadius = 8
        blurView.colorTint = #colorLiteral(red: 0.01960784314, green: 0.05098039216, blue: 0.1411764706, alpha: 0.8)
        blurView.colorTintAlpha = 0.8
        blurView.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceHeight)
        return blurView
    }
    
    /// Returns the blur view used as overlay while presenting an alert
    ///
    /// - Returns: The `VisualEffectView` object
    static func alertBlurOverlay() -> VisualEffectView {
        let blurView = VisualEffectView()
        blurView.blurRadius = 5
        blurView.colorTint = UIColor.searchBarBlack.withAlphaComponent(1)
        blurView.colorTintAlpha = 0.8
        blurView.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceHeight)
        return blurView
    }
    
    /// Returns the blur view used as overlay while presenting loader
    ///
    /// - Returns: The `VisualEffectView` object
    static func loaderBlurOverlay() -> VisualEffectView {
        let blurView = VisualEffectView()
        blurView.blurRadius = 2
//        blurView.colorTint = UIColor.searchBarBlack.withAlphaComponent(1)
        blurView.colorTintAlpha = 0.8
        blurView.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceHeight)
        return blurView
    }
    
    /// Loads view from nib
    ///
    /// - Returns: instance
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    /// Set constant attribute. Example: constrain(.Width, to: 17)
    public func constrain(_ at: NSLayoutAttribute, to: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: at, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: ratio, constant: to)
        addConstraint(constraint)
        return constraint
    }
    
    /// Pin subview at a specific place. Example: constrain(label, at: .Top)
    public func constrain(_ subview: UIView, at: NSLayoutAttribute, diff: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: subview, attribute: at, relatedBy: relation, toItem: self, attribute: at, multiplier: ratio, constant: diff)
        addConstraint(constraint)
        return constraint
    }
    
    /// Pin two subviews to each other. Example:
    ///
    /// constrain(label, at: .Leading, to: textField)
    ///
    /// constrain(textField, at: .Top, to: label, at: .Bottom, diff: 8)
    public func constrain(_ subview: UIView, at: NSLayoutAttribute, to subview2: UIView, at at2: NSLayoutAttribute = .notAnAttribute, diff: CGFloat = 0, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        let at2real = at2 == .notAnAttribute ? at : at2
        let constraint = NSLayoutConstraint(item: subview, attribute: at, relatedBy: relation, toItem: subview2, attribute: at2real, multiplier: ratio, constant: diff)
        addConstraint(constraint)
        return constraint
    }
    
    /// Add subview pinned to specific places. Example: addConstrainedSubview(button, constrain: .CenterX, .CenterY)
    public func addConstrainedSubview(_ subview: UIView, constrain: NSLayoutAttribute...) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        return constrain.map { self.constrain(subview, at: $0) }
    }
    
    // MARK: - Basic Properties
    
    /// view origin x
    var x: CGFloat {
        set { frame = CGRect(x: _pixelIntegral(newValue), y: y, width: width, height: height) }
        get { return frame.origin.x }
    }

    /// view origin y
    var y: CGFloat {
        set { frame = CGRect(x: x, y: _pixelIntegral(newValue), width: width, height: height) }
        get { return frame.origin.y }
    }
    
    /// view width
    var width: CGFloat {
        set { frame = CGRect(x: x, y: y, width: _pixelIntegral(newValue), height: height) }
        get { return frame.size.width }
    }
    
    /// view height
    var height: CGFloat{
        set { frame = CGRect(x: x, y: y, width: width, height: _pixelIntegral(newValue)) }
        get { return frame.size.height }
    }
    
    // MARK: - Origin and Size
    
    /// view origin
    var origin: CGPoint{
        set { frame = CGRect(x: _pixelIntegral(newValue.x), y: _pixelIntegral(newValue.y), width: width, height: height) }
        get { return frame.origin }
    }
    
    /// view size
    var size: CGSize{
        set { frame = CGRect(x: x, y: y, width: _pixelIntegral(newValue.width), height: _pixelIntegral(newValue.height)) }
        get { return frame.size }
    }
    
    // MARK: - Extra Properties
    
    /// view origin right
    var right: CGFloat{
        set { x = newValue - width }
        get { return x + width }
    }
    
    /// view origin bottom
    var bottom: CGFloat{
        set { y = newValue - height }
        get { return y + height }
    }
    
    /// view origin top
    var top: CGFloat {
        set { y = newValue }
        get { return y }
    }
    
    /// view origin left
    var left: CGFloat {
        set { x = newValue }
        get { return x }
    }
    
    /// view center x
    var centerX: CGFloat{
        set { center = CGPoint(x: newValue, y: centerY) }
        get { return center.x }
    }
    
    /// view center y
    var centerY: CGFloat {
        set { center = CGPoint(x: centerX, y: newValue) }
        get { return center.y }
    }
    
    // MARK: - Bounds Methods
    var boundsX: CGFloat {
        set { bounds = CGRect(x: _pixelIntegral(newValue), y: boundsY, width: boundsWidth, height: boundsHeight) }
        get{ return bounds.origin.x }
    }
    
    var boundsY: CGFloat {
        set { frame = CGRect(x: boundsX, y: _pixelIntegral(newValue), width: boundsWidth, height: boundsHeight) }
        get { return bounds.origin.y }
    }
    
    var boundsWidth: CGFloat{
        set { frame = CGRect(x: boundsX, y: boundsY, width: _pixelIntegral(newValue), height: boundsHeight) }
        get { return bounds.size.width }
    }
    
    var boundsHeight: CGFloat{
        set { frame = CGRect(x: boundsX, y: boundsY, width: boundsWidth, height: _pixelIntegral(newValue)) }
        get { return bounds.size.height }
    }
    
    // MARK: - Useful Methods
    
    
    /// Centers view related to superview
    func centerToParent(){
        if(superview != nil){
            switch(UIApplication.shared.statusBarOrientation){
            case .landscapeLeft:
                fallthrough
            case .landscapeRight:
                origin = CGPoint(x: (superview!.height / 2) - (width / 2),
                                 y: (superview!.width / 2) - (height / 2))
            case .portrait:
                fallthrough
            case .portraitUpsideDown:
                origin = CGPoint(x: (superview!.width / 2) - (width / 2),
                                 y: (superview!.height / 2) - (height / 2))
            case .unknown:
                return
            }
        }
    }
    
    
    /// Adds blurred backgound
    func addBlurBackground() {
        backgroundColor = .clear
        let container = UIView()
        container.backgroundColor = .clear
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        
        let blur = VisualEffectView()
        blur.blurRadius = 5
        blur.colorTint = UIColor.venuesGalleryBackgroundColor
        blur.colorTintAlpha = 0.8
        container.addSubview(blur)
        blur.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(container)
        }
    }
    
    // MARK: - Animations
    
    /// Performs fading animation with removing the view from its superview on completion.
    ///
    /// - Parameter duration: fading animation duration
    func removeFromSuperviewAnimated(duration: TimeInterval, completion: (()->())? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
            completion?()
        })
    }
    
    // MARK: - Private Methods
    fileprivate func _pixelIntegral(_ pointValue:CGFloat) -> CGFloat{
        let scale   = UIScreen.main.scale
        return (round(pointValue * scale) / scale)
    }
    
}

class TriangleUpView: UIView {
    
    let colorLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorLayer.fillColor = UIColor.barSelectorColor.cgColor
        layer.addSublayer(colorLayer)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.close()
        colorLayer.path = path.cgPath
    }
    
}

@IBDesignable
final class GradientInspectableView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        layer.addSublayer(gradient)
    }
}
