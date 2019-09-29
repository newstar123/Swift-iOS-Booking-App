//
//  NotificationExtension.swift
//  Qorum
//
//  Created by Stanislav on 15.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    /// Creates a notification with a given sender and posts it to
    /// the notification center.
    /// - Parameter object: the object posting the notification.
    func post(object: Any? = nil) {
        NotificationCenter.default.post(name: self, object: object)
    }
    
    /// Adds an entry to the notification center's dispatch table with an observer
    /// and a notification selector and sender.
    /// - Parameters:
    ///   - observer: object registering as an observer
    ///   - selector: selector that specifies the message the receiver sends observer to notify it of the notification posting.
    ///   - object: the object whose notifications the observer wants to receive
    func add(observer: Any, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: self,
                                               object: object)
    }
    
    /// Adds an entry to the notification center's dispatch table that includes
    /// a notification queue and a block to add to the queue and sender.
    /// - Parameters:
    ///   - object: the object whose notifications the observer wants to receive
    ///   - queue: the operation queue to which block should be added.
    ///   - handler: the block to be executed when the notification is received.
    /// - Returns: an opaque object to act as the observer.
    @discardableResult
    func addObserver(object: Any? = nil,
                     queue: OperationQueue? = nil,
                     handler: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: self,
                                                      object: object,
                                                      queue: queue,
                                                      using: handler)
    }
    
    /// Removes matching entries from the notification center's dispatch table.
    ///
    /// - Parameters:
    ///   - observer: observer to remove from the dispatch table
    ///   - object: sender to remove from the dispatch table
    func remove(observer: Any, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: self, object: object)
    }
    
}

