//
//  GridView.swift
//  Qorum
//
//  Created by Sergey Sivak on 1/16/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import VisualEffectView

private class PhotoGridViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.top.equalTo(self)
            make.right.bottom.equalTo(self)
        }
        
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let _ = imageView
    }
}

private class VideoGridViewCell: PhotoGridViewCell {
    
    lazy var playView: UIView = {
        let container = UIView()
        let blur = VisualEffectView()
        blur.blurRadius = 5
        blur.colorTint = .white
        blur.colorTintAlpha = 0.2
        container.addSubview(blur)
        container.cornerRadius = 32
        blur.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(container)
        }
        
        let playImage = UIImageView(image: UIImage(named: "video_play_icon"))
        playImage.contentMode = .scaleAspectFit
        container.addSubview(playImage)
        playImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(container).offset(2)
            make.centerY.equalTo(container)
            make.height.equalTo(29)
            make.width.equalTo(23)
        }
        
        addSubview(container)
        container.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
        
        return container
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let _ = playView
    }
}

/// The grid mode gallery view designed for the Venue Details scene.
class GridView: UIView {
    
    var venue: Venue?
    weak var venueDetailVC: VenueDetailsViewController?
    
    lazy var navHeight: CGFloat = {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        return statusBarHeight + 42
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: bounds, collectionViewLayout: layout)
        addSubview(view)
        view.contentInset.top = navHeight + 8
        view.contentInset.left = 12
        view.contentInset.right = 12
        view.snp.makeConstraints { make in
            make.top.left.equalTo(self)
            make.width.height.equalTo(self)
        }
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    lazy var navigationBackground: VisualEffectView = {
        let view = VisualEffectView()
        view.blurRadius = 5
        view.colorTint = .black
        view.colorTintAlpha = 0.5
        
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
        butt.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.contentView.addSubview(butt)
        butt.snp.makeConstraints({ (make) in
            make.left.equalTo(view.contentView.snp.left).offset(18)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(32)
        })
        
        let gridView = UIImageView(image: UIImage(named: "close_grid_icon"))
        view.contentView.addSubview(gridView)
        gridView.snp.makeConstraints { make in
            make.right.equalTo(view.contentView.snp.right).offset(-22)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(16)
        }
        
        let gridButton = UIButton(type: .custom)
        gridButton.setTitle("", for: .normal)
        gridButton.frame = .init(x: 0, y: 0, width: 22, height: 22)
        gridButton.addTarget(self, action: #selector(backToGallery), for: .touchUpInside)
        view.contentView.addSubview(gridButton)
        gridButton.snp.makeConstraints { make in
            make.right.equalTo(view.contentView.snp.right).offset(-18)
            make.centerY.equalTo(view.contentView.snp.centerY).offset(10)
            make.height.width.equalTo(32)
        }
        
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.contentOffset.y = navigationBackground.height
        backgroundColor = .black
    }
    
    @objc func close() {
        venueDetailVC?.closeGalleryGridPressed()
    }
  
    @objc func backToGallery() {
        venueDetailVC?.closeGalleryGridPressed(selectedIndex: venueDetailVC?.gallery.currentInd)
    }
    
    
    func fillFromVenue(venue info: Venue, delegate: VenueDetailsViewController) {
        venue = info
        venueDetailVC = delegate
        collectionView.register(PhotoGridViewCell.self, forCellWithReuseIdentifier: "photoPreviewCell")
        collectionView.register(VideoGridViewCell.self, forCellWithReuseIdentifier: "videoPreviewCell")
        collectionView.reloadData()
        bringSubview(toFront: navigationBackground)
    }
    
}

extension GridView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let videosCount = venue!.video_url != .none && venue!.video_thumbnail_url != .none ? 1 : 0
        let photosCount = venue!.gallery_urls.count
        
        return videosCount + photosCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if let player = venueDetailVC?.gallery.playerView?.player, let thumbLink = venue?.video_thumbnail_url {
            if indexPath.row == 0 {
                let videoPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoPreviewCell", for: indexPath) as! VideoGridViewCell
                if let thumbImage = player.currentThumbnail {
                    videoPreviewCell.imageView.image = thumbImage
                } else {
                    videoPreviewCell.imageView.pin_setImage(from: URL(string: "\(kCacheURL)\(thumbLink)"))
                    videoPreviewCell.imageView.pin_updateWithProgress = true
                }
                videoPreviewCell.imageView.setupForGallery()
                videoPreviewCell.bringSubview(toFront: videoPreviewCell.playView)
                cell = videoPreviewCell
            } else {
                let photoPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoPreviewCell", for: indexPath) as! PhotoGridViewCell
                let link = venue!.gallery_urls[indexPath.row - 1]
                photoPreviewCell.imageView.pin_updateWithProgress = true
                photoPreviewCell.imageView.pin_setImage(from: URL(string: "\(kCacheURL)\(link)"))
                photoPreviewCell.imageView.setupForGallery()
                cell = photoPreviewCell
            }
        } else {
            let photoPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoPreviewCell", for: indexPath) as! PhotoGridViewCell
            let link = venue!.gallery_urls[indexPath.row]
            photoPreviewCell.imageView.pin_updateWithProgress = true
            photoPreviewCell.imageView.pin_setImage(from: URL(string: "\(kCacheURL)\(link)"))
            photoPreviewCell.imageView.setupForGallery()
            cell = photoPreviewCell
        }
        
        return cell
    }
}

extension GridView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitem = 12 as CGFloat
        let leftspace = collectionView.contentInset.left as CGFloat
        let rightspace = collectionView.contentInset.right as CGFloat
        let side = (.deviceWidth - interitem - leftspace - rightspace) / 2
        
        return .init(width: side, height: side)
    }
}

extension GridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        removeFromSuperview()
        venueDetailVC?.closeGalleryGridPressed(selectedIndex: indexPath.row)
    }
}
