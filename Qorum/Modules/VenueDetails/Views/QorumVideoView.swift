//
//  QorumVideoView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 7/20/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SnapKit
import VisualEffectView

/// The video player view designed for the Venue Details gallery.
class QorumVideoView: UIView {
    
    let player = QorumPlayer()
    
    private(set) lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        return playerLayer
    }()
    
    var thumb: UIImageView?
    var playView = UIView()
    var timeObserver: Any?
    let expandButton = UIButton(type: .custom)
    let lenghtLabel = UILabel(font: UIFont.montserrat.semibold(10), textColor: .white, text: "")
    weak var delegate: QorumVideoDelegate?
    var userPaused = false
    var isExpanded = false {
        didSet {
            updateExpandButton()
        }
    }
    
    override var frame: CGRect {
        didSet {
            playerLayer.frame = bounds
            let expanded = ((bounds.height == .deviceHeight && bounds.width == .deviceWidth) || (bounds.width == .deviceHeight && bounds.height == .deviceWidth))
            playerLayer.videoGravity = expanded ? .resizeAspect : .resizeAspectFill
            thumb?.contentMode = expanded ? .scaleAspectFit : .scaleAspectFill
            isExpanded = expanded
        }
    }
    
    var isPlaying: Bool {
        return player.isPlaying
    }
    
    // MARK: -
    
    deinit {
        finishSession()
        self.player.removeTimeObserver(self.timeObserver!)
        NotificationCenter.default.removeObserver(self)
    }
    
    init(with url: String,
         thumbnail: String?,
         delegate: QorumVideoDelegate,
         expanded: Bool,
         frame: CGRect = CGRect(x: 0, y: 0, width: .deviceWidth, height: .deviceWidth))
    {
        super.init(frame: frame)
        setup(with: url,
              thumbnail: thumbnail,
              delegate: delegate,
              expanded: expanded)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with url: String, thumbnail: String?, delegate: QorumVideoDelegate, expanded: Bool) {
        // We resume the system music playback on entering background
        Notification.Name.UIApplicationWillResignActive
            .add(observer: self, selector: #selector(finishSession))
        self.clipsToBounds = true
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: url)!))
        player.actionAtItemEnd = .pause
        
        // None of muted videos should interrupt system music playback.
        startMutedSession()
        player.isMuted = true
        player.delegate = self
        self.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(userPressedPlay)))
        isExpanded = expanded
        expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
        expandButton.adjustsImageWhenDisabled = false
        // expandButton?.isHidden = !expanded
        self.addSubview(expandButton)
        
        if thumbnail != nil {
            thumb = UIImageView(frame: self.bounds)
            thumb?.contentMode = expanded ? .scaleAspectFit : .scaleAspectFill
            thumb?.pin_updateWithProgress = true
            thumb?.pin_setImage(from: URL(string: "\(kCacheURL)\(thumbnail!)"))
            self.addSubview(thumb!)
            thumb?.snp.makeConstraints { (make) in
                make.top.left.bottom.right.equalTo(self)
            }
        }
        
        playView.backgroundColor = .clear
        self.addSubview(playView)
        playView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.height.width.equalTo(64)
        }
        
        let blur = VisualEffectView()
        blur.blurRadius = 5
        blur.colorTint = .white
        blur.colorTintAlpha = 0.2
        playView.addSubview(blur)
        playView.cornerRadius = 32
        blur.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(playView)
        }
        
        let playButton = UIButton(type: .custom)
        playButton.setImage(UIImage(named: "video_play_icon"), for: .normal)
        playButton.addTarget(self, action: #selector(userPressedPlay), for: .touchUpInside)
        playButton.adjustsImageWhenDisabled = false
        playView.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(playView).offset(2)
            make.centerY.equalTo(playView)
            make.height.equalTo(29)
            make.width.equalTo(23)
        }
        
        self.addSubview(lenghtLabel)
        
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 2), queue: DispatchQueue.main) { [weak self] time in
            guard self != nil else {
                return
            }
            
            let currentProgress = CGFloat(CMTimeGetSeconds(time))
            let min = Int(CGFloat(currentProgress/60).rounded(.down))
            let sec = Int(currentProgress) - min*60
            let text = String(format: "\(min):%02i", sec)
            self?.lenghtLabel.text = text
        }
        
        self.delegate = delegate
    }
    
    func updateLayout(insets: UIEdgeInsets) {
        expandButton.snp.removeConstraints()
        lenghtLabel.snp.removeConstraints()
        expandButton.snp.makeConstraints { make in
            make.height.width.equalTo(36)
            make.bottom.equalToSuperview().offset(-insets.bottom - 8)
            make.right.equalToSuperview().offset(-insets.right - 16)
        }
        lenghtLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(insets.left + 16)
            make.bottom.equalToSuperview().offset(-insets.bottom - 12)
        }
    }
    
    @objc func shouldPlay() {
        if player.isPlaying {
            if player.isMuted {
                unmuteSession()
                player.isMuted = false
                return
            }
            player.pause()
        } else {
            player.play()
        }
    }
    
    func playMuted() {
        player.play()
    }
    
    func stopPlaying() {
        player.pause()
    }
    
    func updateExpandButton() {
        expandButton.setImage(UIImage(named: isExpanded ? "Expanded_View_Icon" : "Expand_View_Icon"), for: .normal)
    }
    
    @objc func expand() {
        isExpanded = !isExpanded
        delegate?.expandVideo()
    }
    
    @objc func userPressedPlay() {
        userPaused = player.isPlaying && !player.isMuted
        shouldPlay()
    }
    
    // MARK: -
    
    /// Prevents system music playback interruption
    func startMutedSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set AVAudioSession category:", error)
        }
    }
    
    /// Interrupts system music playback
    func unmuteSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set AVAudioSession category:", error)
        }
    }
    
    /// Resumes system music playback
    @objc func finishSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set AVAudioSession category:", error)
        }
    }
    
}

// MARK: -
protocol QorumVideoDelegate: NSObjectProtocol {
    
    func expandVideo()
    
    func didStartPlayingVideo(in videoView: QorumVideoView)
    
    func didStopPlayingVideo(in videoView: QorumVideoView)
}

// MARK: - QorumPlayerDelegate
extension QorumVideoView: QorumPlayerDelegate {
    
    func playerStateChanged(in player: QorumPlayer) {
        switch player.playerState {
        case .loading:
            thumb?.isHidden = false
        case .playing:
            if  !player.isMuted,
                AVAudioSession.sharedInstance().categoryOptions.contains(.mixWithOthers)
            {
                unmuteSession()
            }
            thumb?.isHidden = true
            delegate?.didStartPlayingVideo(in: self)
        case .stalled:
            thumb?.isHidden = true
            delegate?.didStopPlayingVideo(in: self)
        case .paused:
            thumb?.isHidden = true
            expandButton.isHidden = false
            delegate?.didStopPlayingVideo(in: self)
        case .finished:
            thumb?.isHidden = false
            userPaused = true
            player.seek(to: kCMTimeZero)
            delegate?.didStopPlayingVideo(in: self)
            finishSession()
        }
        isUserInteractionEnabled = !player.isLoading
        playView.alpha = player.isLoading ? 0.5 : 1
        playView.isHidden = player.isPlaying || (!userPaused && !player.isLoading)
    }
    
}

