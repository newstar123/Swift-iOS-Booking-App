//
//  UIImageExtentions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/24/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import ImageIO

extension UIImageView {
    
    
    /// Adds fading animation
    ///
    /// - Parameters:
    ///   - duration: animation duration
    ///   - completion: completion block
    func addFadingTransition(duration: TimeInterval = AnimationDuration.Long,
                             completion: (() -> Void)? = nil) {
        layer.removeAnimation(forKey: kCATransition)
        let fadeTransition = CATransition()
        fadeTransition.duration = duration
        fadeTransition.type = kCATransitionFade
        layer.add(fadeTransition, forKey: kCATransition)
        if let completion = completion {
            delayToMainThread(fadeTransition.duration) {
                completion()
            }
        }
    }
    
    /// Prepares gallery image
    func setupForGallery() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
    }
    
}

extension UIImage {
    
    /// Normalizes image to avoid rotated presentation
    ///
    /// - Returns: image instance
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl: String) -> UIImage? {
        guard let bundleURL = URL(string: gifUrl) else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
//        if b == nil || a == nil {
//            if b != nil {
//                return b
//            } else if a != nil {
//                return a
//            } else {
//                return 0
//            }
//        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a % b
            
            if rest == 0 {
                return b
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    /// Returns animated with given source
    ///
    /// - Parameter source: source image
    /// - Returns: result image
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    /// Returns image instance colored with given color
    ///
    /// - Parameters:
    ///   - color: image color
    ///   - size: image size
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: img!.cgImage!)
    }
    
}

/// Returns rotated image instance from given source
///
/// - Parameters:
///   - oldImage: source image
///   - degrees: degrees to rotate
/// - Returns: result image
func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
    let t: CGAffineTransform = .rotation(degrees: degrees)
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    //Rotate the image context
    bitmap.rotate(by: (degrees * CGFloat.pi / 180))
    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}
