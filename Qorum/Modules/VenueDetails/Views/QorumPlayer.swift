//
//  QorumPlayer.swift
//  Qorum
//
//  Created by Stanislav on 09.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum QorumPlayerState {
    case loading
    case playing
    case stalled
    case paused
    case finished
}

protocol QorumPlayerDelegate: class {
    func playerStateChanged(in player: QorumPlayer)
}

/// The video player designed for the Venue Details gallery.
class QorumPlayer: AVPlayer {
    
    weak var delegate: QorumPlayerDelegate? {
        didSet {
            if delegate != nil {
                addObservers()
            } else {
                removeObservers()
            }
        }
    }
    
    private(set) var playerState: QorumPlayerState = .finished {
        didSet {
            if playerState != oldValue {
                delegate?.playerStateChanged(in: self)
            }
        }
    }
    
    var isPlaying: Bool {
        switch playerState {
        case .playing: return true
        default: return false
        }
    }
    
    var isLoading: Bool {
        switch playerState {
        case .loading: return true
        default: return false
        }
    }
    
    deinit {
        print("player deinit")
        removeObservers()
    }
    
    override func play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
            
        catch {
            print("Silent mode enabling error")
        }
        
        super.play()
    }
    
    fileprivate func addObservers() {
        addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    fileprivate func removeObservers() {
        removeObserver(self, forKeyPath: "rate", context: nil)
        removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" || keyPath == "currentItem.playbackLikelyToKeepUp" {
            guard let item = currentItem else {
                playerState = .finished
                return
            }
            let currentSeconds = item.currentTime().seconds
            if rate > 0 {
                if item.isPlaybackLikelyToKeepUp {
                    playerState = .playing
                } else {
                    if currentSeconds <= 0 {
                        playerState = .loading
                    } else {
                        playerState = .stalled
                    }
                }
            } else {
                guard playerState != .finished else { return }
                if currentSeconds >= item.duration.seconds {
                    playerState = .finished
                    print("Video Finished")
                } else {
                    playerState = .paused
                }
            }
        }
    }
    
    
    var currentThumbnail: UIImage? {
        let image: UIImage?
        do {
            guard let asset = currentItem?.asset else { throw NSError(domain: "No item is currently loaded", code: -1) }
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let imageRef = try imageGenerator.copyCGImage(at: currentTime(), actualTime: nil)
            let thumbnail = UIImage(cgImage:imageRef)
            image = thumbnail
        } catch {
            debugPrint("thumbnal of current video cannot be created", error)
            image = .none
        }
        
        return image
    }
}


