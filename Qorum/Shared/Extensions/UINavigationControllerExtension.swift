//
//  UINavigationControllerExtension.swift
//  Qorum
//
//  Created by Stanislav on 04.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    static var root: UINavigationController? {
        return UIViewController.rootViewController as? UINavigationController
    }
    
    /// Pushes the view controller animated with a handler on completion.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - completion: Pushing animation completion handler.
    public func pushViewControllerAnimated(_ viewController: UIViewController,
                                           completion: @escaping () -> Void) {
        pushViewController(viewController, animated: true)
        guard let coordinator = transitionCoordinator else {
            completion()
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
    
    /// Pops to the view controller animated with a handler on completion.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - completion: Pushing animation completion handler.
    public func popToViewControllerAnimated(_ viewController: UIViewController,
                                           completion: @escaping () -> Void) {
        popToViewController(viewController, animated: true)
        guard let coordinator = transitionCoordinator else {
            completion()
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
    
}


