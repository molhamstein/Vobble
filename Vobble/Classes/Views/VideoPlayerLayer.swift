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
import TransitionButton

@objc protocol VideoPlayerDelegate {
    @objc optional func didCompleteVideo()
    @objc optional func didSeenVideo()
    @objc optional func shakeVideoView()
}

class VideoPlayerLayer: AbstractNibView {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var slideBar: UISlider!
    
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var player: AVPlayer?
    fileprivate var asset: AVAsset?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var url: URL?
    fileprivate var playButton: TransitionButton?
    fileprivate var delegate: VideoPlayerDelegate?
    
    public var isAutoPlay: Bool = false
    
    func configure(url: String, isAutoPlay: Bool = false, customButton: TransitionButton, delegate: VideoPlayerDelegate) {
        if let videoURL = URL(string: url) {
            
            self.isAutoPlay = isAutoPlay
            self.url = videoURL
            self.playButton = customButton
            self.delegate = delegate
            
            asset = AVAsset(url: videoURL)
            playerItem = AVPlayerItem(asset: asset!)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResize
            
            loader.hidesWhenStopped = true
            
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            
            bringSubview(toFront: loader)
            
            addObservers()
            
            setupTapGesture()
            
            // To make sure there is no other sound is playing
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: .mixWithOthers)
                } else {
                    // Fallback on earlier versions
                }
            } catch {
                print(error.localizedDescription)
            }
            
            // Notify when the video is played to the end
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            
            
        }else {
            print("Faild to load")
        }
    }
    
    func addObservers(){
        // This observer for seek bar
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
                    
                    if seconds == 3 {
                        self?.delegate?.didSeenVideo!()
                    }
                }
            }
        }
        
        playerItem?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
    }
    
    func setupTapGesture(){
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func reachTheEndOfTheVideo(_ notification: Notification) {
        stop()
        delegate?.didCompleteVideo!()
    }
    
    @objc
    func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        playButtonPressed()
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            
            if #available(iOS 10.0, *) {
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                
                if newStatus != oldStatus {
                    DispatchQueue.main.async {[weak self] in
                        
                        if self?.isAutoPlay ?? false {
                            if newStatus == .playing {
                                
                                self?.playButton?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0 , completion: {
                                    self?.playButton?.setImage(UIImage(named: "pause"), for: .normal)
                                })
                            }else if newStatus == .paused {
                                //self?.playButton?.setImage(UIImage(named: "ic_play"), for: .normal)
                                self?.playButton?.stopAnimation(animationStyle: .normal, revertAfterDelay: 0 , completion: {
                                    self?.playButton?.setImage(UIImage(named: "ic_play"), for: .normal)
                                })
                            }else {
                                self?.playButton?.setImage(UIImage(named: "pause"), for: .normal)
                                self?.playButton?.startAnimation()
                            }
                        }
                    }
                }
                
            } else {
                // Fallback on earlier versions
            }
            
        }else if keyPath == "status" {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                if self.isAutoPlay {
                    play()
                }else{
                    pause()
                }
            case .failed:
                return
            case .unknown:
                return
            }
        }
    }
    
}

// MARK:- Player Control Functions
extension VideoPlayerLayer {
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
    
    func isPlaying() -> Bool {
        if let player = self.player {
            if #available(iOS 10.0, *) {
                if player.timeControlStatus == AVPlayer.TimeControlStatus.playing {
                    return true
                }
            } else {
                // Fallback on earlier versions
            }
        }
        return false
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
            asset.cancelLoading()
            playerItem.cancelPendingSeeks()
            playerItem.removeObserver(self, forKeyPath: "status", context: nil)
            player.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            player.cancelPendingPrerolls()
            player.replaceCurrentItem(with: nil)
            
            stop()
        }
    }
    
    func reloadVideoPrerolls(){
        if let player = player {
            player.preroll(atRate: 0, completionHandler: nil)
            play()
        }
    }
    
    func playButtonPressed() {
        if isPlaying() {
            pause()
        }else {
            play()
        }
    }
}
