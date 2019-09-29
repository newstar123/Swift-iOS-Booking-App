//
//  UIColorExtensions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/10/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var baseViewBackgroundColor: UIColor {
        return UIColor(hex: "050d25")!
    }
    
    static var accessButtonBorderColor: UIColor {
        return UIColor(hex: "979797")!
    }
    
    static var darkBlueBackground: UIColor {
        return UIColor(in8bit: 26, 35, 72)
    }
    
    static var lightBlueColor: UIColor {
        return UIColor(in8bit: 28, 172, 219)
    }
    
    static var transparentBlueBackground: UIColor {
        return UIColor(in8bit: 26, 35, 72, alpha: 0.2)
    }
    
    static var searchBarBlack: UIColor {
        return UIColor(in8bit: 5, 13, 36, alpha: 0.6)
    }
    
    static var darkGreenBorder: UIColor {
        return UIColor(in8bit: 127, 186, 182)
    }
    
    static var verifiedGreen: UIColor {
        return UIColor(in8bit: 0, 142, 83)
    }
    
    static var darkGreenCheckInBorder: UIColor {
        return UIColor(in8bit: 127, 186, 128, alpha: 0.8)
    }
    
    static var barSelectorColor: UIColor {
        return UIColor(in8bit: 100, 175, 208)
    }
    
    static var drinksBackgroundColor: UIColor {
        return UIColor(in8bit: 96, 170, 219)
    }
    
    static var rateReviewGrayColor: UIColor {
        return UIColor(in8bit: 170, 170, 170)
    }
    
    static var venuesGalleryBackgroundColor: UIColor {
        return UIColor(in8bit: 5, 13, 36)
    }
    
    static var facebookColor: UIColor {
        return UIColor(hex: "3b5998")!
    }
    
    static var uberColor: UIColor {
        return UIColor(hex: "138B90")!
    }
    
    static var overlayTintColor: UIColor {
        return UIColor(in8bit: 245, 166, 35)
    }
    
    static var detailsFeaturesGrey: UIColor {
        return UIColor(in8bit: 130, 134, 145)
    }
    
    static var loaderBlueColor: UIColor {
        return UIColor(in8bit: 21, 162, 215)
    }
    
    static var loaderMiddleColor: UIColor {
        return UIColor(in8bit: 41, 176, 141)
    }
    
    static var loaderGreenColor: UIColor {
        return UIColor(in8bit: 81, 180, 96)
    }
    
    /// Inits UIColor instance from hex string
    ///
    /// - Parameter hex: hex color
    convenience init?(hex: String) {
        guard let rgbValue = UInt(hex, radix: 16) else {return nil}
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue: CGFloat(rgbValue & 0xFF)/255.0, alpha: 1)
    }
    
    /// Inits UIColor instance from RGB values
    ///
    /// - Parameters:
    ///   - red: R value for red
    ///   - green: G value for green
    ///   - blue: B value for blue
    ///   - alpha: alpha value
    convenience init(in8bit red: UInt8, _ green: UInt8, _ blue: UInt8, alpha: CGFloat = 1) {
        let div: CGFloat = 255
        self.init(red: CGFloat(red)/div,
                  green: CGFloat(green)/div,
                  blue: CGFloat(blue)/div,
                  alpha: alpha)
    }
    
    static func venueColor(_ venueType: String) -> UIColor {
        let mainType = venueType.components(separatedBy: "/").first ?? ""
        switch mainType.lowercased() {
        case "beer garden": return UIColor(red: 0.0, green: 0.67, blue: 0.87, alpha: 1)
        case "cocktail bar": return UIColor(red: 0.26, green: 0.34, blue: 0.89, alpha: 1)
        case "gastropub": return UIColor(red: 0.46, green: 0.34, blue: 0.92, alpha: 1)
        case "lounge": return UIColor(red: 0.58, green: 0.13, blue: 0.56, alpha: 1)
        case "music venue": return UIColor(red: 0.78, green: 0.51, blue: 0.18, alpha: 1)
        case "neighborhood bar": return UIColor(red: 0.38, green: 0.75, blue: 0.39, alpha: 1)
        case "nightclub": return UIColor(red: 0.71, green: 0.25, blue: 0.68, alpha: 1)
        case "pub": return UIColor(red: 0.69, green: 0.80, blue: 0.28, alpha: 1)
        case "rooftop": return UIColor(red: 0.86, green: 0.62, blue: 0.33, alpha: 1)
        case "speakeasy": return UIColor(red: 0.12, green: 0.71, blue: 0.64, alpha: 1)
        case "sports bar": return UIColor(red: 0.80, green: 0.68, blue: 0.18, alpha: 1)
        case "wine bar": return UIColor(red: 0.72, green: 0.43, blue: 0.91, alpha: 1)
        default: return UIColor.lightBlueColor
        }
    }
    
}
