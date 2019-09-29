//
//  UNNotificationAttachmentExtension.swift
//  Qorum
//
//  Created by Vadym Riznychok on 1/19/18.
//  Copyright © 2018 Bizicosoft. All rights reserved.
//

import UserNotifications

extension UNNotificationAttachment {
    
    /// Creates attachment for UNNotification
    ///
    /// - Parameters:
    ///   - identifier: attachment id
    ///   - image: attachment image
    ///   - options: attachment options
    /// - Returns: created instance
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}

extension UNMutableNotificationContent {
    
    /// Creates UNMutableNotificationContent instance
    ///
    /// - Parameters:
    ///   - title: notification content id
    ///   - body: notification content body
    ///   - venue: venue to include in notification content
    ///   - categoryIdentifier: notification content category id
    /// - Returns: UNMutableNotificationContent instance
    static func create(with title: String? = nil, body: String, venue: Venue? = nil, categoryIdentifier: String? = nil) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        if title != nil {
            content.title = title!
        }
        content.body = body
        content.sound = UNNotificationSound.default()
        if venue != nil {
            content.addImage(from: venue!)
        }
        if categoryIdentifier != nil {
            content.categoryIdentifier = categoryIdentifier!
        }
        return content
    }
    
    /// Adds image venue
    ///
    /// - Parameter venue: venue instance
    func addImage(from venue: Venue) {
        if  let urlStr = venue.main_photo_url,
            let url = URL(string: urlStr)
        {
            do {
                if  let image = try UIImage(data: Data(contentsOf: url)),
                    let attachment = UNNotificationAttachment.create(identifier: "CheckedInImage", image: image, options: [:])
                {
                    self.attachments = [attachment]
                    return
                }
            } catch { }
        }
        
        print("UNMutableNotificationContent venue image parsing issue. URL string: \(venue.main_photo_url ?? "empty")")
    }
    
}
