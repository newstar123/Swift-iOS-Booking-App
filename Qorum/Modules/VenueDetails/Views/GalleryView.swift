//
//  GalleryView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/27/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import VisualEffectView

enum GalleryState {
    case short
    case expanded
}

/// The gallery view designed for the Venue Details scene.
class GalleryView: UIScrollView {
    
    var venue: Venue?
    weak var venueDetailVC: VenueDetailsViewController?
    var playerView: QorumVideoView?
    var state: GalleryState = .short
    
    var currentInd = 0
    var viewHeight: CGFloat = 0
    var viewWidth: CGFloat = 0
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "OpenSans", size: 19)
        label.textColor = .white
        label.textAlignment = .center
        navigationBackground.contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(navigationBackground.contentView.snp.left).offset(0)
            make.centerY.equalTo(navigationBackground.contentView.snp.centerY).offset(10)
            make.right.equalTo(navigationBackground.contentView.snp.right).offset(0)
            make.height.equalTo(30)
        }
        
        return label
    }()
    
    lazy var navHeight: CGFloat = {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 42
    }()
    
    lazy var navigationBackground: VisualEffectView = {
        let view = VisualEffectView()
        view.blurRadius = 5
        view.colorTint = .black
        view.colorTintAlpha = 0.5
        
        view.tag = 1232423
        view.isHidden = true
        
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.height.equalTo(navHeight)
            make.width.equalTo(self.width)
            make.top.left.equalTo(self)
        }
        let backView = UIImageView(image: UIImage(named: "Close_Gallery_Icon"))
        view.contentView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(view.contentView.snp.left).offset(23)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(16)
        }
        
        let butt = UIButton(type: .custom)
        butt.setTitle("", for: .normal)
        butt.frame = CGRect(x: 18, y: 27, width: 22, height: 22)
        butt.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.contentView.addSubview(butt)
        butt.snp.makeConstraints({ (make) in
            make.left.equalTo(view.contentView.snp.left).offset(18)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(32)
        })
        
        let gridView = UIImageView(image: UIImage(named: "Grid_Gallery_Icon"))
        view.contentView.addSubview(gridView)
        gridView.snp.makeConstraints { make in
            make.right.equalTo(view.contentView.snp.right).offset(-22)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(16)
        }
        
        let gridButton = UIButton(type: .custom)
        gridButton.setTitle("", for: .normal)
        gridButton.frame = .init(x: 0, y: 0, width: 22, height: 22)
        gridButton.addTarget(self, action: #selector(openGrid), for: .touchUpInside)
        view.contentView.addSubview(gridButton)
        gridButton.snp.makeConstraints { make in
            make.right.equalTo(view.contentView.snp.right).offset(-18)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(32)
        }
        
        return view
    }()
    
    let videoViewInsets: UIEdgeInsets = {
        return UIApplication.shared.safeAreaInsets
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let landFix = isViewLandscape()
        
        if state == .short {
            if viewHeight == self.height && viewWidth == .deviceWidth {
                return
            }
            viewHeight = self.height
            viewWidth = .deviceWidth
        } else {
            if viewHeight == (landFix == true ? .deviceWidth : .deviceHeight) && viewWidth == (landFix == true ? .deviceHeight : .deviceWidth) {
                return
            }
            viewHeight = landFix == true ? .deviceWidth : .deviceHeight
            viewWidth = landFix == true ? .deviceHeight : .deviceWidth
            
            adjustContent()
        }
        
        if playerView != nil {
            playerView!.height = viewHeight
            playerView!.width = viewWidth
            playerView!.layoutIfNeeded()
        }
        
        subviews.filter({$0 is UIScrollView}).forEach { (view) in
            view.height = viewHeight
            view.width = viewWidth
            (view as! UIScrollView).contentSize.height = viewHeight
            (view as! UIScrollView).contentSize.width = viewWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .black
    }
    
    //MARK: - Update
    
    func updateLabel() {
        if venueDetailVC != nil {
            pageLabel.text = "\(Int(self.contentOffset.x / (isViewLandscape() ? .deviceHeight : .deviceWidth)) + 1) of \(venueDetailVC!.pageControl.numberOfPages)"
        } else {
            pageLabel.text = "some"
        }
    }
    
    func fillFromVenue(venue: Venue, delegate: VenueDetailsViewController) {
        self.venue = venue
        self.venueDetailVC = delegate
        var videoShowed = 0
        if let url = venue.video_url, let thumb = venue.video_thumbnail_url {
            let videoView = QorumVideoView(with: url, thumbnail: thumb, delegate: self, expanded: false)
            videoView.tag = 666
            videoView.playMuted()
            playerView = videoView
            
            addSubview(playerView!)
            playerView!.updateLayout(insets: .zero)
            videoShowed = 1
            contentSize.width += .deviceWidth
        }
        
        let galleryList: [String] = Array(venue.gallery_urls)
        for (i, url) in galleryList.enumerated() {
            let scrollView = UIScrollView(frame: CGRect(x: .deviceWidth * CGFloat(i + videoShowed), y: 0, width: .deviceWidth, height: .deviceWidth))
            scrollView.maximumZoomScale = 1
            scrollView.isUserInteractionEnabled = true
            let imgFrame = scrollView.bounds
            let photo = UIImageView(frame: imgFrame)
            photo.pin_updateWithProgress = true
            photo.pin_setImage(from: URL(string: "\(kCacheURL)\(url)"))
            photo.setupForGallery()
            scrollView.addSubview(photo)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
            scrollView.addGestureRecognizer(tap)
            
            self.addSubview(scrollView)
            scrollView.delegate = self
        }
        self.bringSubview(toFront: navigationBackground)
        updateLabel()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        let orientationNotification = Notification.Name.UIDeviceOrientationDidChange
        orientationNotification.remove(observer: self)
        orientationNotification.add(observer: self, selector: #selector(didChangeOrientation))
    }
    
    func display(state: GalleryState) {
        self.state = state
        switch state {
        case .short:
            subviews.filter({$0 is UIScrollView}).forEach({ (view) in
                (view.subviews.first as! UIImageView).contentMode = .scaleAspectFill
                (view as! UIScrollView).maximumZoomScale = 1
                (view as! UIScrollView).zoomScale = 1
            })
            
            self.contentSize.height = .deviceWidth
            navigationBackground.isHidden = true
            setPrefersStatusBar(hidden: false)
            self.transform = .rotation(degrees: 0)
            if let playerView = playerView {
                playerView.updateLayout(insets: .zero)
            }
        case .expanded:
            subviews.filter({$0 is UIScrollView}).forEach({ (view) in
                (view.subviews.first as! UIImageView).contentMode = .scaleAspectFit
                (view as! UIScrollView).maximumZoomScale = 4
            })
            
            if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight) {
                adjustLandscape(left: UIDevice.current.orientation == .landscapeLeft)
            } else {
                navigationBackground.isHidden = false
                if let playerView = playerView {
                    playerView.updateLayout(insets: videoViewInsets)
                }
            }
        }
    }
    
    @objc func closeTapped() {
        let orientation = UIDevice.current.orientation
        if state == .expanded && (orientation == .landscapeLeft || orientation == .landscapeRight) {
            forcePortrait()
            self.venueDetailVC?.openGalleryPressed()
            return
        }
        
        venueDetailVC?.openGalleryPressed()
    }
    
    @objc func openGrid() {
        venueDetailVC?.openGalleryGridPressed(currentIndex: currentInd)
    }
    
    //MARK: - Rotations
    @objc func didChangeOrientation() {
        guard state == .expanded else {
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                closeTapped()
            }
            return
        }
        
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.unknown:
            print("Unknown")
        case UIDeviceOrientation.portrait:
            print("Portrait")
            adjustPortrait()
        case UIDeviceOrientation.portraitUpsideDown:
            print("PortraitUpsideDown")
        case UIDeviceOrientation.landscapeLeft:
            print("LandscapeLeft")
            adjustLandscape(left: true)
        case UIDeviceOrientation.landscapeRight:
            print("LandscapeRight")
            adjustLandscape(left: false)
        case UIDeviceOrientation.faceUp:
            print("FaceUp")
        case UIDeviceOrientation.faceDown:
            print("FaceDown")
        }
    }
    
    func adjustPortrait() {
        guard !isViewPortrait() else { return }
        
        setPrefersStatusBar(hidden: false)
        navigationBackground.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.transform = .rotation(degrees: 0)
        }
        if let playerView = playerView {
            playerView.updateLayout(insets: videoViewInsets)
        }
        self.setNeedsLayout()
    }
    
    @objc func adjustLandscape(left: Bool) {
        let degrees: CGFloat = left ? 90 : -90
        guard self.transform != .rotation(degrees: degrees) else { return }
        
        setPrefersStatusBar(hidden: true)
        navigationBackground.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.transform = .rotation(degrees: degrees)
        }
        if let playerView = playerView {
            let sideInset = min(videoViewInsets.top, videoViewInsets.bottom)
            let landscapeInsets = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
            playerView.updateLayout(insets: landscapeInsets)
        }
        self.setNeedsLayout()
    }
    
    func adjustContent() {
        let pageId = currentInd
        
        self.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceHeight)
        
        self.contentSize = CGSize.zero
        self.contentSize.height = viewHeight
        
        var rect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        
        for view in self.subviews {
            if view is UIScrollView || view is QorumVideoView {
                (view as? UIScrollView)?.zoomScale = 1
                view.frame = rect
                if view is UIScrollView {
                    view.subviews.first!.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
                }
                rect.origin.x += viewWidth
                self.contentSize.width += viewWidth
            }
        }
        
        self.contentOffset.x = CGFloat(pageId) * viewWidth
    }
    
    func forcePortrait() {
        let pageId = currentInd
        navigationBackground.isHidden = true
        self.transform = .rotation(degrees: 0)
        if let playerView = playerView {
            playerView.updateLayout(insets: .zero)
        }
        self.setNeedsLayout()
        
        self.frame = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceHeight)
        
        self.contentSize = CGSize.zero
        self.contentSize.height = .deviceWidth
        
        var rect = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceWidth)
        
        for view in self.subviews {
            if view is UIScrollView || view is QorumVideoView {
                (view as? UIScrollView)?.zoomScale = 1
                view.frame = rect
                if view is UIScrollView {
                    view.subviews.first!.frame = view.bounds
                }
                rect.origin.x += .deviceWidth
                self.contentSize.width += .deviceWidth
            }
        }
        
        self.contentOffset.x = CGFloat(pageId) * .deviceWidth
    }
    
    func isViewPortrait() -> Bool {
        return self.transform == .rotation(degrees: 0)
    }
    
    func isViewLandscape() -> Bool {
        return self.transform == .rotation(degrees: -90) || self.transform == .rotation(degrees: 90)
    }
    
    func setPrefersStatusBar(hidden: Bool) {
        venueDetailVC?.shouldHideStatusBar = hidden
    }

}

extension GalleryView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
}

extension GalleryView: QorumVideoDelegate {
    
    func didStartPlayingVideo(in videoView: QorumVideoView) {
        venueDetailVC?.configureSpecialNoticeVisibility()
    }
    
    func didStopPlayingVideo(in videoView: QorumVideoView) {
        venueDetailVC?.configureSpecialNoticeVisibility()
    }
    
    
    func expandVideo() {
        closeTapped()
    }
    
}
