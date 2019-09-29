//
//  UIFontExtension.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/1/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
    
    struct montserrat {
        
        static func medium(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Medium", size: size)!
        }
        
        static func regular(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Regular", size: size)!
        }
        
        static func light(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Light", size: size)!
        }
        
        static func bold(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-Bold", size: size)!
        }
        
        static func semibold(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Montserrat-SemiBold", size: size)!
        }
    }
    
    struct opensans {
        
        static func `default`(_ size:CGFloat) -> UIFont {
            return  UIFont(name: "OpenSans", size: size)!
        }
        
        static func light(_ size:CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Light", size: size)!
        }
        
        static func semibold(_ size:CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Semibold", size: size)!
        }
        
        static func semibold_italic(_ size:CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-SemiboldItalic", size: size)!
        }
        
        static func bold(_ size:CGFloat) -> UIFont {
            return UIFont(name: "OpenSans-Bold", size: size)!
        }
    }
    

}


