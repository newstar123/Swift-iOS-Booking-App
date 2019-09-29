//
//  VenueTransitionAnimator.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/21/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

private extension UIView {
    
    /// converts view frame according to the window's coordinate system
    var frameRelatedToWindow: CGRect {
        return superview?.convert(frame, to: .none) ?? frame
    }
    
}

typealias Pair<T> = (T, T)

class VenueTransitionAnimator: NSObject {
    
    /// transition animation duration
    var duration: TimeInterval
    
    /// indicates push transition
    var isPresenting: Bool
    
    init(duration: TimeInterval,
         isPresenting: Bool)
    {
        self.duration = duration
        self.isPresenting = isPresenting
    }
    
    /// Animates transition to Venue Details screen
    ///
    /// - Parameters:
    ///   - fromView: source view
    ///   - toView: destination view
    ///   - container:
    ///   - cell: cell to present from
    ///   - detail: Venue Details Controller
    ///   - completion: completion block
    func animate(fromView: UIView,
                 toView: UIView,
                 container: UIView,
                 cell: VenuesCollectionCell,
                 detail: VenueDetailsViewController,
                 completion: @escaping ()->()) {
        let detailView = isPresenting ? toView : fromView
        
        /* name view transition */
        let nameView: Pair<UILabel> = (cell.name, detail.nameLabel)
        
        let transitionName = UILabel()
        transitionName.numberOfLines = 2
        transitionName.text = nameView.0.text
        transitionName.font = nameView.0.font
        transitionName.textColor = nameView.0.textColor
        transitionName.textAlignment = nameView.0.textAlignment
        transitionName.frame = isPresenting
            ? nameView.0.frameRelatedToWindow
            : nameView.1.frameRelatedToWindow
        container.addSubview(transitionName)
        
        /* icon view transition */
        let iconView: Pair<UIImageView> = (cell.venueIcon, detail.venueTypeIcon)
        
        let transitionIcon = UIImageView()
        transitionIcon.image = iconView.0.image
        transitionIcon.contentMode = iconView.0.contentMode
        transitionIcon.tintColor = iconView.0.tintColor
        transitionIcon.frame = isPresenting
            ? iconView.0.frameRelatedToWindow
            : iconView.1.frameRelatedToWindow
        container.addSubview(transitionIcon)
        
        /* type view transition */
        let typeView: Pair<UILabel> = (cell.type, detail.venueTypeLabel)
        
        let transactionType = UILabel()
        transactionType.text = typeView.0.text
        transactionType.font = typeView.0.font
        transactionType.textColor = typeView.0.textColor
        transactionType.textAlignment = typeView.0.textAlignment
        transactionType.frame = isPresenting
            ? typeView.0.frameRelatedToWindow
            : typeView.1.frameRelatedToWindow
        container.addSubview(transactionType)
        
        /* discount view transition */
        let discountView: Pair<UILabel>?
        let transitionDiscountLabel: UILabel?
        if !cell.discount.isHidden {
            let discount: Pair<UILabel> = (cell.discount, detail.discountLabel)
            let transitionDiscount = UILabel()
            transitionDiscount.text = isPresenting
                ? discount.0.text
                : discount.1.text
            transitionDiscount.font = discount.1.font
            transitionDiscount.textAlignment = discount.1.textAlignment
            let discountTranformScaleX = discount.0.width / discount.1.width
            let discountTranformScaleY = discount.0.height / discount.1.height
            transitionDiscount.transform = self.isPresenting
                ? CGAffineTransform(scaleX: discountTranformScaleX, y: discountTranformScaleY)
                : CGAffineTransform(scaleX: 1, y: 1)
            transitionDiscount.textColor = isPresenting
                ? discount.0.textColor
                : discount.1.textColor
            transitionDiscount.frame = isPresenting
                ? discount.0.frameRelatedToWindow
                : discount.1.frameRelatedToWindow
            container.addSubview(transitionDiscount)
            discountView = (discount.0, discount.1)
            transitionDiscountLabel = transitionDiscount
        } else {
            discountView = nil
            transitionDiscountLabel = nil
        }
        
        /* distance view transition */
        let distanceView: Pair<UILabel> = (cell.distance, detail.distanceLabel)
        
        let transitionDistance = UILabel()
        transitionDistance.text = isPresenting
            ? distanceView.0.text
            : distanceView.1.text
        transitionDistance.font = distanceView.1.font
        transitionDistance.textAlignment = .right
        let distanceTranformScaleX = distanceView.0.width / distanceView.1.width
        let distanceTranformScaleY = distanceView.0.height / distanceView.1.height
        transitionDistance.transform = self.isPresenting
            ? CGAffineTransform(scaleX: distanceTranformScaleX, y: distanceTranformScaleY)
            : CGAffineTransform(scaleX: 1, y: 1)
        transitionDistance.textColor = isPresenting
            ? distanceView.0.textColor
            : distanceView.1.textColor
        transitionDistance.frame = isPresenting
            ? distanceView.0.frameRelatedToWindow
            : distanceView.1.frameRelatedToWindow
        container.addSubview(transitionDistance)
        
        /* fade out 'cutted' objects from both views */
        nameView.0.alpha = 0.0
        nameView.1.alpha = 0.0
        
        iconView.0.alpha = 0.0
        iconView.1.alpha = 0.0
        
        typeView.0.alpha = 0.0
        typeView.1.alpha = 0.0
        
        discountView?.0.alpha = 0.0
        discountView?.1.alpha = 0.0
        
        distanceView.0.alpha = 0.0
        distanceView.1.alpha = 0.0
        
        /* animate fake views */
        toView.alpha = isPresenting ? 0 : 1
        let cellToDetailTransition = isPresenting
        
        UIView.animate(withDuration: duration, animations: {
            /* fade animation */
            detailView.alpha = !cellToDetailTransition ? 0 : 1
            /* name animation */
            transitionName.frame = !cellToDetailTransition
                ? nameView.0.frameRelatedToWindow
                : nameView.1.frameRelatedToWindow
            /* icon animation */
            transitionIcon.frame = !cellToDetailTransition
                ? iconView.0.frameRelatedToWindow
                : iconView.1.frameRelatedToWindow
            /* type animation */
            transactionType.frame = !cellToDetailTransition
                ? typeView.0.frameRelatedToWindow
                : typeView.1.frameRelatedToWindow
            /* discount animation */
            if let transitionDiscount = transitionDiscountLabel, let discountView = discountView {
                transitionDiscount.text = !cellToDetailTransition
                    ? discountView.0.text
                    : discountView.1.text
                let discountTranformScaleX = discountView.0.width / discountView.1.width
                let discountTranformScaleY = discountView.0.height / discountView.1.height
                transitionDiscount.transform = !cellToDetailTransition
                    ? CGAffineTransform(scaleX: discountTranformScaleX, y: discountTranformScaleY)
                    : CGAffineTransform(scaleX: 1, y: 1)
                transitionDiscount.textColor = !cellToDetailTransition
                    ? discountView.0.textColor
                    : discountView.1.textColor
                transitionDiscount.frame = !cellToDetailTransition
                    ? discountView.0.frameRelatedToWindow
                    : discountView.1.frameRelatedToWindow
            }
            /* distance animation */
            transitionDistance.text = !cellToDetailTransition
                ? distanceView.0.text
                : distanceView.1.text
            transitionDistance.transform = !cellToDetailTransition
                ? CGAffineTransform(scaleX: distanceTranformScaleX, y: distanceTranformScaleY)
                : CGAffineTransform(scaleX: 1, y: 1)
            transitionDistance.textColor = !cellToDetailTransition
                ? distanceView.0.textColor
                : distanceView.1.textColor
            transitionDistance.frame = !cellToDetailTransition
                ? cell.distance.frameRelatedToWindow
                : detail.distanceLabel.frameRelatedToWindow
        }) { _ in
            /* remove fake objects */
            transitionName.removeFromSuperview()
            transitionIcon.removeFromSuperview()
            transactionType.removeFromSuperview()
            transitionDiscountLabel?.removeFromSuperview()
            transitionDistance.removeFromSuperview()
            
            /* fade in 'cutted' objects from both views */
            nameView.0.alpha = 1.0
            nameView.1.alpha = 1.0
            
            iconView.0.alpha = 1.0
            iconView.1.alpha = 1.0
            
            typeView.0.alpha = 1.0
            typeView.1.alpha = 1.0
            
            discountView?.0.alpha = 1.0
            discountView?.1.alpha = 1.0
            
            distanceView.0.alpha = 1.0
            distanceView.1.alpha = 1.0
            
            completion()
        }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension VenueTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
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
        guard
            let detail = transitionContext.viewController(forKey: isPresenting ? .to : .from) as? VenueDetailsViewController,
            let listVC = transitionContext.viewController(forKey: isPresenting ? .from : .to) as? VenuesViewController,
            let cell = listVC.selectedCell else
        {
            let animator = FadeAnimator(duration: duration, isPresenting: isPresenting)
            animator.animate(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            return
        }
        animate(fromView: fromView, toView: toView, container: container, cell: cell, detail: detail) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
