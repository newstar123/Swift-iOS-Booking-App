//
//  VenuesCollectionCell.swift
//  Qorum
//
//  Created by Vadym Riznychok on 10/9/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import PINRemoteImage
import PINCache
import VisualEffectView

enum TabActivityType {
    case view
    case open
    case none
}

class VenuesCollectionCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var venueIcon: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var discountContainer: VisualEffectView!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var notice: UIImageView!
    @IBOutlet weak var fbCount: UILabel!
    @IBOutlet weak var fbImage: UIImageView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var hoursContainer: UIView!
    @IBOutlet weak var parallaxTop: NSLayoutConstraint!
    @IBOutlet weak var parallaxBot: NSLayoutConstraint!
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var actionView: UIView!
    
    weak var slideindicator: UIView?
    
    var contentOffsetX: CGFloat = 0.0
    
    var onVenueOpenTabInteraction: (() -> ())?
    
    var onVenueViewTabInteraction: (() -> ())?
    
    var onVenueDetailsInteraction: (() -> ())?
    
    var id: Int?
    
    var imgDiff: CGFloat = 100
    
    var tabActivityType: TabActivityType = .none
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateParallax(onView: UIApplication.shared.topMostViewController?.view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        discountContainer.blurRadius = 5
        discountContainer.colorTint = UIColor.searchBarBlack.withAlphaComponent(1)
        discountContainer.colorTintAlpha = 0.6
        actionLabel.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        clear()
    }

    
    func clear() {
        name.text = ""
        image.image = nil
        fbCount.text = ""
        fbImage.isHidden = true
        name.isHidden = false
        discount.isHidden = false
        notice.isHidden = false
        discountContainer.isHidden = false
        slideindicator?.removeFromSuperview()
    }
    
    func fillWith(venue: Venue) {
        clear()
        
        id = venue.venue_id
        name.text = venue.name
        image.pin_updateWithProgress = true
        let placeholder = #imageLiteral(resourceName: "VenueCellPlaceholder")
        if let mainImageURL = venue.main_photo_url {
            let imageLink = "\(kCacheURL)\(mainImageURL)"
            image.pin_setImage(from: URL(string: imageLink),
                               placeholderImage: placeholder)
        } else {
            image.image = placeholder
        }
        
        type?.text = venue.venueTypeText
        distance.text = venue.distanceText
        if let discountValue = venue.discount, discountValue >= 0 {
            discount.text = String(format: "%.0f%@", arguments: [discountValue, NSLocalizedString("% OFF", comment: "")])
            discount.isHidden = false
        } else {
            discount.isHidden = true
        }
        
        notice.isHidden = venue.specialNotice == .none || venue.specialNotice?.isEmpty == true
        
        if  discount.isHidden &&
            notice.isHidden
        {
            discountContainer.isHidden = true
        }
        
        let checkedInFriends = venue.checkedInFriends.count
        if checkedInFriends > 0 {
            fbCount.text = String(describing: checkedInFriends)
            fbImage.isHidden = false
            fbCount.sizeToFit()
        } else {
            fbCount.text = ""
            fbImage.isHidden = true
        }
        fillDate(venue: venue)
        layoutIfNeeded()
    }
    
    func updateTabActivityType(with venue: Venue,
                               mayOpenTab: Bool) {
        if venue.isCheckedIn {
            tabActivityType = .view
        } else if
            venue.isNearby,
            venue.isOpen,
            mayOpenTab
        {
            tabActivityType = .open
        } else {
            tabActivityType = .none
        }
        addAccessoryTapIndicatorIfNeeded()
        addAccessorySlideIndicatorIfNeeded()
    }
    
    func addAccessoryTapIndicatorIfNeeded() {
        let isScrollAllowed: Bool
        let cellXOffset: CGFloat
        switch tabActivityType {
        case .view:
            isScrollAllowed = true
            cellXOffset = 15
            actionLabel.isHidden = false
            actionIcon.isHidden = false
            actionLabel.text = "VIEW TAB"
            actionView.isHidden = false
        case .open:
            isScrollAllowed = true
            cellXOffset = 15
            actionLabel.isHidden = false
            actionIcon.isHidden = false
            actionLabel.text = "OPEN TAB"
            actionView.isHidden = false
        case .none:
            isScrollAllowed = false
            cellXOffset = 0
            actionLabel.isHidden = true
            actionIcon.isHidden = true
            actionView.isHidden = true
        }
        contentOffsetX = cellXOffset
        scrollView.contentInset.left = -cellXOffset
        scrollView.contentOffset = .init(x: cellXOffset, y: 0)
        scrollView.isScrollEnabled = isScrollAllowed
    }
    
    func addAccessorySlideIndicatorIfNeeded() {
        guard scrollView.isScrollEnabled else { return }
        guard User.stored.settings.isListTabAccessoryEverSlided == false else { return }
        let loader = ArrowsView()
        loader.transform = CGAffineTransform(rotationAngle: -.pi/2)
        detailView.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.addConstraints([
            loader.widthAnchor.constraint(equalToConstant: 40),
            loader.heightAnchor.constraint(equalToConstant: 54)
        ])
        detailView.addConstraints([
            loader.centerYAnchor.constraint(equalTo: detailView.centerYAnchor),
            loader.rightAnchor.constraint(equalTo: detailView.rightAnchor, constant: -16)
        ])
        slideindicator = loader
    }
    
    func fillDate(venue: Venue) {
        venueIcon.tintColor = .venueColor(venue.venue_type ?? "")
        let status = venue.status()
        hoursContainer.backgroundColor = status.indicatorColor.withAlphaComponent(0.86)
        hoursLabel.text = status.indicatorText.uppercased()
        switch status {
        case .open:
            hoursContainer.isHidden = true
        case .closesSoon, .opensLater, .closed:
            hoursContainer.isHidden = false
        }
    }
    
    // MARK: - Parallax
    
    func updateParallax(onView: UIView?) {
        guard let holderView = onView else {
            self.parallaxTop.constant = 0
            self.parallaxBot.constant = 0
            self.layoutIfNeeded()
            return
        }
        
        let posYInSuperview = self.convert(self.bounds, to: holderView).origin.y + self.bounds.height
        let posRatio = posYInSuperview/(.deviceHeight + self.bounds.height)
        let parallaxPos = self.imgDiff * posRatio
        
        let botConst = -(self.imgDiff - parallaxPos)
        let topConst = -(self.imgDiff) - botConst

        if botConst < 0, topConst < 0 {
            parallaxBot.constant = botConst
            parallaxTop.constant = topConst
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapDetailsView() {
        onVenueDetailsInteraction?()
    }
    
    @IBAction func didTapActionView() {
        handleAccessoryAction()
    }
    
    fileprivate func handleAccessoryAction() {
        switch tabActivityType {
        case .open: onVenueOpenTabInteraction?()
        case .view: onVenueViewTabInteraction?()
        case .none: onVenueDetailsInteraction?()
        }
    }
    
}

extension VenuesCollectionCell: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x - scrollView.contentInset.left >= detailView.frame.minX + (detailView.frame.size.width * 0.8).rounded(.toNearestOrAwayFromZero) {
            User.stored.settings.isListTabAccessoryEverSlided = true
            handleAccessoryAction()
        }
        let point = CGPoint(x: contentOffsetX, y: 0)
        scrollView.setContentOffset(point, animated: true)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let point = CGPoint(x: contentOffsetX, y: 0)
        scrollView.setContentOffset(point, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let point = CGPoint(x: contentOffsetX, y: 0)
        if scrollView.contentOffset != point {
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
}
