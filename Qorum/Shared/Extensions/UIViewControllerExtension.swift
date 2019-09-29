//
//  UIViewControllerExtension.swift
//  Qorum
//
//  Created by Stanislav on 13.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

// MARK: - Child view controller adding/removing
extension UIViewController {
    
    /// Adds viewController as child controller
    ///
    /// - Parameters:
    ///   - childViewController: controller to add
    ///   - parentView: source view in wich child controller will be presented
    func add(childViewController: UIViewController, to parentView: UIView? = nil) {
        addChildViewController(childViewController)
        if let parentView = parentView, view.allSubviews.contains(parentView) {
            parentView.addSubview(childViewController.view)
        } else {
            view.addSubview(childViewController.view)
        }
        childViewController.didMove(toParentViewController: self)
    }
    
    /// Removes view controller from parent
    func removeFromParentController() {
        guard parent != nil else { return }
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
}

// MARK: - Navigation
extension UIViewController {
    
    /// current root view controller
    static var rootViewController: UIViewController? {
        return AppDelegate.shared.window?.rootViewController
    }
    
    /// currently visible view controller
    var topMostViewController: UIViewController? {
        if let visibleViewController = (self as? UINavigationController)?.visibleViewController {
            return visibleViewController.topMostViewController
        }
        if let selectedViewController = (self as? UITabBarController)?.selectedViewController {
            return selectedViewController.topMostViewController
        }
        if let presentedViewController = presentedViewController {
            return presentedViewController.topMostViewController
        }
        return self
    }
    
    /// currently visible view controller excluding alerts
    var topMostFullScreenViewController: UIViewController {
        let mayPresentOn: (UIViewController) -> Bool = { viewController in
            return viewController.isFullScreenStyle && type(of: viewController).description() != "SFAuthenticationViewController"
        }
        if let navigationController = self as? UINavigationController {
            if let visibleVC = navigationController.visibleViewController {
                if mayPresentOn(visibleVC) {
                    return visibleVC.topMostFullScreenViewController
                }
                if let topVC = navigationController.topViewController {
                    return topVC.topMostFullScreenViewController
                }
            }
        }
        if let selectedVC = (self as? UITabBarController)?.selectedViewController {
            return selectedVC.topMostFullScreenViewController
        }
        if let presentedVC = presentedViewController, mayPresentOn(presentedVC) {
            return presentedVC.topMostFullScreenViewController
        }
        if  let presentingVC = presentingViewController, !mayPresentOn(self) {
            return presentingVC
        }
        return self
    }
    
    /// Returns an index of the view controller in its navigation controller stack
    /// returns nil, if the view controller missing its navigation controller
    var navigationStackIndex: Int? {
        return navigationController?.viewControllers.index(of: self)
    }
    
    /// Returns the last presenting view controller, which is presented in full screen style
    /// Returns nil, if top most view controller already presented in full screen style
    var lastFullSreenPresentingViewController: UIViewController? {
        if  let presentingVC = presentingViewController, !isFullScreenStyle {
            return presentingVC.lastFullSreenPresentingViewController
        }
        if self === self.topMostViewController {
            return nil
        }
        return self
    }
    
    var isFullScreenStyle: Bool {
        return modalPresentationStyle == .custom ||
            modalPresentationStyle == .fullScreen ||
            modalPresentationStyle == .overFullScreen
    }
    
    /// Looks for view controller in navigation stack that matches specified type
    ///
    /// - Parameters:
    ///   - type: The UIViewController subclass to look for
    ///   - predicate: Optional predicate closure for more detailed filter
    /// - Returns: The first view controller in navigation stack matching specified type and predicate
    func find<VC: UIViewController>(_ type: VC.Type,
                                    where predicate: ((VC) -> Bool)? = nil) -> VC? {
        if let navigationController = (self as? UINavigationController) ?? self.navigationController {
            return navigationController.viewControllers.find(type, where: predicate)
        }
        if let vc = self as? VC, predicate?(vc) ?? true {
            return vc
        }
        return nil
    }
    
    /// Whether specified view controller is pushed above the view controller in its navigation stack
    ///
    /// - Parameter viewController: The view controller to compare navigation stack position against
    /// - Returns: `true` if the view controller is under specified view controller in its navigation stack
    func isUnder(_ viewController: UIViewController) -> Bool {
        guard navigationController === viewController.navigationController else { return false }
        return (navigationStackIndex ?? -1) < (viewController.navigationStackIndex ?? -1)
    }
    
    /// Pushes specified view controller or presents it, if navigation controller is missing
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push/present
    ///   - animated: Whether it will be animated transition or not
    ///   - completion: The block to be executed after the `viewController` is pushed/presented
    func open(viewController: UIViewController,
              animated: Bool = true,
              completion: (() -> ())? = nil) {
        guard let navController = navigationController ?? self as? UINavigationController else {
            if let lastFullScreenVC = lastFullSreenPresentingViewController {
                lastFullScreenVC.dismiss(animated: true) {
                    lastFullScreenVC.open(viewController: viewController, animated: animated, completion: completion)
                }
            }
            let navigationController = viewController as? UINavigationController ?? BaseNavigationController(rootViewController: viewController)
            navigationController.isNavigationBarHidden = true
            present(navigationController, animated: animated, completion: completion)
            return
        }
        guard let completion = completion else {
            navController.pushViewController(viewController, animated: animated)
            return
        }
        if animated {
            navController.pushViewControllerAnimated(viewController, completion: completion)
        } else {
            navController.pushViewController(viewController, animated: false)
            completion()
        }
    }
    
}

// MARK: - Animations
extension UIViewController {
    
    /// Same as UIView.animate(withDuration:animations:completion),
    /// but with adding a blocking overlay view onto the view controller's view,
    /// and removing it on the completion.
    func animateDisablingActions(duration: TimeInterval,
                                 animations: @escaping ()->(),
                                 completion: @escaping ()->()) {
        let blockingOverlayView = UIView(frame: view.bounds)
        view.addSubview(blockingOverlayView)
        UIView.animate(withDuration: duration, animations: animations) { _ in
            blockingOverlayView.removeFromSuperview()
            completion()
        }
    }
    
    func animateDisablingActions(duration: TimeInterval,
                                 animations: @escaping ()->()) {
        animateDisablingActions(duration: duration,
                                animations: animations,
                                completion: { })
    }
    
}


