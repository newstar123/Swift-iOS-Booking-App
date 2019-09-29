//
//  FadeAnimator.swift
//  Qorum
//
//  Created by Stanislav on 16.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class FadeAnimator: NSObject {
    
    /// transition animation duration
    var duration: TimeInterval
    
    /// indicates push transition
    var isPresenting: Bool
    
    init(duration: TimeInterval, isPresenting: Bool) {
        self.duration = duration
        self.isPresenting = isPresenting
    }
    
    /// Performs transition animation
    ///
    /// - Parameters:
    ///   - fromView: source view
    ///   - toView: destination view
    ///   - completion: completion block
    func animate(fromView: UIView,
                 toView: UIView,
                 completion: @escaping ()->()) {
        let detailView = isPresenting ? toView : fromView
        toView.alpha = isPresenting ? 0 : 1
        UIView.animate(withDuration: duration, animations: {
            detailView.alpha = self.isPresenting ? 1 : 0
        }) { _ in
            completion()
        }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension FadeAnimator: UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else { return }
        if isPresenting {
            container.addSubview(toView)
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        animate(fromView: fromView, toView: toView) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
}

