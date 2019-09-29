//
//  UITableViewExtension.swift
//  Qorum
//
//  Created by Stanislav on 10/17/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Scrolls to the first row
    ///
    /// - Parameter animated: true for animation enabled
    func scrollToTop(animated: Bool) {
        if animated {
            flashScrollIndicators()
        }
        let indexPath = IndexPath(row: 0, section: 0)
        scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    /// Scrolls to the last row
    ///
    /// - Parameter animated: true for animation enabled
    func scrollToBottom(animated: Bool) {
        if animated {
            flashScrollIndicators()
        }
        let indexPath = IndexPath(row: numberOfRows(inSection: numberOfSections - 1) - 1,
                                  section: numberOfSections - 1)
        scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
}
