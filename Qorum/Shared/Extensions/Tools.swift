//
//  Tools.swift
//  Qorum
//
//  Created by Vadym Riznychok on 9/26/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import PINRemoteImage
import DeviceKit

extension CGAffineTransform {
    
    static func rotation(degrees: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: degrees.toRadians)
    }
    
}

extension UIButton {
    
    var highlightedColor: UIColor {
        get {
            return UIColor.white
        } set {
            setBackgroundImage(UIImage(color: newValue), for: UIControlState.highlighted)
        }
    }
        
}

extension CGFloat {
    
    var toRadians: CGFloat {
        return Angle(self, .degrees).converted(to: .radians)
    }
    
    static var deviceHeight: CGFloat {
        let size = UIScreen.main.bounds.size
        return Swift.max(size.height, size.width)
    }
    
    static var deviceWidth: CGFloat {
        let size = UIScreen.main.bounds.size
        return Swift.min(size.height, size.width)
    }
    
}

extension Int {
    var monetaryValue: String {
        var val:Double = Double(self)
        val = val / 100
        return val.monetaryValue
    }
}

extension Double {
    var monetaryValue: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        if let formatted = formatter.string(from: self as NSNumber) {
            return formatted
        }
        return "0.00"
    }
    
    var gratuityValue: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        if let formatted = formatter.string(from: self as NSNumber) {
            return formatted
        }
        return "0"
    }
}

extension String {
    
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    
    var isValidEmail: Bool {
        return String.emailPredicate.evaluate(with: self)
    }
    
    /// Convenience URL init
    var url: URL? {
        return URL(string: self)
    }
    
    func versionNumber(digits: Int) -> Int {
        let array = self.split(separator: ".")
        var result: Int = 0
        for index in (0..<digits) {
            let element = index < array.count ? array[index] : "1"
            if let value = Int(element) {
                let decimalValue = NSDecimalNumber(decimal: (Decimal(value) * pow(10, digits - index - 1)))
                result = result + Int(truncating: decimalValue)
            }
        }
        return result
    }

    
    
    /// Embeds specified link in HTML
    ///
    /// - Parameter link: HTTP/S link as interaction destination
    /// - Returns: HTML formatted link aliased with original string
    func htmlLinked(with link: String) -> String {
        return "<a href=\"\(link)\">\(self)</a>"
    }
    
}

extension UIApplication {
    
    var topMostViewController: UIViewController? {
        return UIViewController.rootViewController?.topMostViewController
    }
    
    var topMostFullScreenViewController: UIViewController? {
        return UIViewController.rootViewController?.topMostFullScreenViewController
    }
    
    var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return keyWindow?.safeAreaInsets ?? .zero
        }
        if let rootVC = UIViewController.rootViewController {
            return UIEdgeInsets(top: rootVC.topLayoutGuide.length,
                                left: 0,
                                bottom: rootVC.bottomLayoutGuide.length,
                                right: 0)
        }
        if statusBarOrientation == .portrait, !isStatusBarHidden {
            return UIEdgeInsets(top: statusBarFrame.height, left: 0, bottom: 0, right: 0)
        }
        return .zero
    }
    
}

extension NSLayoutConstraint {
    convenience init(item view1: Any, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation = .equal, toItem view2: Any? = nil, attribute attr2: NSLayoutAttribute? = nil, constant: CGFloat = 0) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2 ?? attr1, multiplier: 1.0, constant: constant)
    }
}

extension Encodable {
    
    func encode() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}

extension Decodable {
    
    static func decoded(from data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
}

extension Device {
    
    var hasHomeButton: Bool {
        switch realDevice {
        case .iPhoneX,
             .iPhoneXs,
             .iPhoneXsMax,
             .iPhoneXr: return false
        default: return !isFaceIDCapable
        }
    }
    
}
