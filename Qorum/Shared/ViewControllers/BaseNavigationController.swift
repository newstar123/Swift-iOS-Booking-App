//
//  BaseNavigationController.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    static var baseRoot: BaseNavigationController? {
        return UINavigationController.root as? BaseNavigationController
    }
    
    private var interactionController: UIPercentDrivenInteractiveTransition?
    
    private(set) lazy var customPopGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleCustomPop(_:)))
        recognizer.edges = .left
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        view.addGestureRecognizer(customPopGestureRecognizer)
    }
    
    /// flag for fade animation transition
    var isFadeInteractorEnabled = true {
        didSet {
            customPopGestureRecognizer.isEnabled = isFadeInteractorEnabled
        }
    }
    
    /// Hadles custom pop transition animation
    ///
    /// - Parameter gestureRecognizer: sender
    @objc func handleCustomPop(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view else { return }
        let progress = gestureRecognizer.translation(in: gestureView).x / gestureView.bounds.size.width
        switch gestureRecognizer.state {
        case .began:
            guard mayBeginPopGestureHandling else { return }
            if topViewController is VenueDetailsViewController {
                interactionController = UIPercentDrivenInteractiveTransition()
                popViewController(animated: true)
            }
        case .changed:
            interactionController?.update(progress)
        case .ended:
            if progress > 0.5 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        case .cancelled, .failed:
            interactionController?.cancel()
            interactionController = nil
        case .possible:
            break
        }
    }
    
    private var mayBeginPopGestureHandling: Bool {
        if let coordinator = transitionCoordinator, coordinator.isAnimated {
            return false
        }
        // enable interactive pop gesture unless it's the root view controller
        return viewControllers.count > 1
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard mayBeginPopGestureHandling else { return false }
        
        switch topViewController {
        case
        is ProfileViewController,
        is EditProfileViewController,
        is InviteViewController,
        is PaymentsViewController,
        is AddNewPaymentViewController,
        is SettingsViewController,
        is LegalNoteViewController,
        is MenuHeaderController,
        is MenuController,
        is TicketTitleViewController,
        is BillViewController:
            return true
        default:
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer === customPopGestureRecognizer
    }
    
}

// MARK: - UINavigationControllerDelegate
extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presenting: Bool
        switch operation {
        case .push: presenting = true
        case .pop: presenting = false
        case .none: return nil
        }
        let duration = 0.4
        switch (fromVC, toVC) {
        case (is AuthViewController, _), (_, is AuthViewController), (is LoadingViewController, is VenuesViewController):
            return FadeAnimator(duration: duration, isPresenting: presenting)
        case (is VenueDetailsViewController, _), (_, is VenueDetailsViewController):
            return VenueTransitionAnimator(duration: duration, isPresenting: presenting)
        default: return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}

