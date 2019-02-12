//
//  VideoPlayerView.swift
//  Vobble
//
//  Created by Bayan on 3/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
//import BMPlayer
import UIKit
import Player
import CoreMedia

class VideoPlayerView: AbstractNibView {
    
    var player: Player!
    var playButton: UIButton!
    var seekTime: CMTime!
    var tolerance: CMTime = CMTimeMakeWithSeconds(0.5, 1)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slideBar: UISlider!
    @IBOutlet weak var videoView: UIView!
    
    public func preparePlayer(videoURL: String,customPlayBtn: UIButton) {
        animateIndicator(animated: true)
        
        self.playButton = customPlayBtn
        self.player = Player()
        self.player.url = URL(string: videoURL)
        
        self.player.playerDelegate = self
        self.player.playbackDelegate = self

        self.videoView.addSubview(player.view)
        self.player.view.bringToFront()
        self.slideBar.bringToFront()
        self.activityIndicator.bringToFront()
        
        self.player.view.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoView.snp.top)
            make.left.equalTo(self.videoView.snp.left)
            make.right.equalTo(self.videoView.snp.right)
            make.bottom.equalTo(self.videoView.snp.bottom)
        }

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
    }

    func playButtonPressed() {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            self.player.playFromBeginning()
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            break
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            break
        case PlaybackState.playing.rawValue:
            self.player.pause()
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        case PlaybackState.failed.rawValue:
            self.player.pause()
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        default:
            self.player.pause()
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
            break
        }
    }
    
}


extension VideoPlayerView {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        playButtonPressed()
    }
    
    @IBAction func didChangeTime(_ sender: UISlider) {
        print("Slider value is: \(sender.value)")
        
        self.player.pause()
        self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        self.seekTime = CMTimeMakeWithSeconds(Float64(Double(sender.value) * Double(self.player.maximumDuration)), 1)
        self.player.seekToTime(to: seekTime, toleranceBefore: self.tolerance, toleranceAfter: self.tolerance)
    }
    
    func isPlaying() -> Bool {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.playing.rawValue:
            return true
        default:
            return false
        }
    }
    
    func isPaused() -> Bool {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.paused.rawValue:
            return true
        default:
            return false
        }
    }
    
    func isStopped() -> Bool {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            return true
        default:
            return false
        }
    }
    
    func animateIndicator(animated: Bool) {
        if animated {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }else {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - PlayerDelegate
extension VideoPlayerView: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        print("\(#function) ready")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        switch player.bufferingState.rawValue {
        case BufferingState.ready.rawValue:
            self.player.playFromCurrentTime()
            animateIndicator(animated: false)
        default:
            animateIndicator(animated: true)
        }
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}

// MARK: - PlayerPlaybackDelegate
extension VideoPlayerView: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
        self.slideBar.setValue(Float(fraction), animated: true)
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        self.slideBar.setValue(0.0, animated: true)
    }
    
}
