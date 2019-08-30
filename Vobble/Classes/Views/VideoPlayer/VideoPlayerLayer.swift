//
//  VideoPlayerView.swift
//  Vobble
//
//  Created by Bayan on 3/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia
import AVFoundation

class VideoPlayerLayer: AbstractNibView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideBar: UISlider!
    //@IBOutlet weak var videoView: UIView!
    
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var player: AVPlayer?
    fileprivate var asset: AVAsset?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var url: URL?
    
    public var isAutoPlay: Bool = false
    
    func configure(url: String, isAutoPlay: Bool = false) {
        if let videoURL = URL(string: url) {
            
            self.isAutoPlay = isAutoPlay
            self.url = videoURL
            
            asset = AVAsset(url: videoURL)
            playerItem = AVPlayerItem(asset: asset!)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResize
            
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
                if let duration = self?.player?.currentItem?.duration {
                    
                    let durationSeconds = CMTimeGetSeconds(duration)
                    let seconds = CMTimeGetSeconds(progressTime)
                    let progress = Float(seconds/durationSeconds)
                    
                    DispatchQueue.main.async {
                        self?.slideBar.value = progress
                        if progress >= 1.0 {
                            self?.slideBar.value = 0.0
                        }
                    }
                }
            }
            
            playerItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: .mixWithOthers)
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                print(error.localizedDescription)
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
    }
    
    func isVideoAvailable() -> Bool{
        if let _ = self.url {
            return true
        }
        return false
    }
    
    func isVideoReady() -> Bool {
        if let playerItem = self.playerItem {
            if playerItem.status == AVPlayerItemStatus.readyToPlay {
                return true
            }
        }
        return false
    }
    
    func cancelBuffring() {
        if let playerItem = self.playerItem, let asset = self.asset, let player = self.player {
            playerItem.cancelPendingSeeks()
            asset.cancelLoading()
            player.cancelPendingPrerolls()
            
            stop()
        }
    }
    
    func reachTheEndOfTheVideo(_ notification: Notification) {
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            
            if #available(iOS 10.0, *) {
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                
                if newStatus != oldStatus {
                    DispatchQueue.main.async {[weak self] in
                        
                        if newStatus == .playing || newStatus == .paused {
                            self?.activityIndicator.stopAnimating()
                        } else {
                            self?.activityIndicator.startAnimating()
                        }
                    }
                }
                
            } else {
                // Fallback on earlier versions
            }
            
        }else if keyPath == "status" {
            if self.playerItem?.status == AVPlayerItemStatus.readyToPlay {
                if isAutoPlay {
                    play()
                }else {
                    pause()
                }
            }
        }
    }
    
}

