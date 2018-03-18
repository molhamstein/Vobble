//
//  VideoPlayerView.swift
//  Vobble
//
//  Created by Bayan on 3/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import BMPlayer
import UIKit

class VideoPlayerView: AbstractNibView {
    
    var player: BMPlayer!
    @IBOutlet weak var videoView: UIView!
    let controller: BMPlayerCustomControlView = BMPlayerCustomControlView()
    
    public func preparePlayer(videoURL: String,customPlayBtn: UIButton) {
        
        resetPlayerManager()
        
//        let controller: BMPlayerCustomControlView = BMPlayerCustomControlView()
        controller.setCustomPlayBtn(playBtn: customPlayBtn)
        player = BMPlayer(customControlView: controller)
        
//        player = BMPlayer()
        
        videoView.addSubview(player)
        
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoView.snp.top)
            make.left.equalTo(self.videoView.snp.left)
            make.right.equalTo(self.videoView.snp.right)
            make.bottom.equalTo(self.videoView.snp.bottom)
        }
        
        player.delegate = self
        
        let asset = BMPlayerResource(url: URL(string: videoURL)!)
        
        
        player.setVideo(resource: asset)
        
    }
    
    func resetPlayerManager() {
        // should print log, default false
        BMPlayerConf.allowLog = false
        // should auto play, default true
        BMPlayerConf.shouldAutoPlay = true
        // main tint color, default whiteColor
        BMPlayerConf.tintColor = UIColor.white
        // options to show header view (which include the back button, title and definition change button) , default .Always，options: .Always, .HorizantalOnly and .None
        BMPlayerConf.topBarShowInCase = .none
        // loader type, see detail：https://github.com/ninjaprox/NVActivityIndicatorView
       // BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
        // enable setting the brightness by touch gesture in the player
        BMPlayerConf.enableBrightnessGestures = true
        // enable setting the volume by touch gesture in the player
        BMPlayerConf.enableVolumeGestures = true
        // enable setting the playtime by touch gesture in the player
        BMPlayerConf.enablePlaytimeGestures = true
    }
    
    func playButtonPressed() {
        controller.delegate?.controlView(controlView: controller, didPressButton: controller.playButton)
    }
    
}


// MARK:- BMPlayerDelegate example
extension VideoPlayerView: BMPlayerDelegate {
    // Call when player orinet changed
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            make.top.equalTo(self.videoView.snp.top)
            make.left.equalTo(self.videoView.snp.left)
            make.right.equalTo(self.videoView.snp.right)
            if isFullscreen {
                make.bottom.equalTo(self.videoView.snp.bottom)
            } else {
                //make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0).priority(500)
                make.bottom.equalTo(self.videoView.snp.bottom)
            }
        }
    }
    
    // Call back when playing state changed, use to detect is playing or not
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
    }
    
    // Call back when play time change
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        //  print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
    }
    
    // Call back when the video loaded duration changed
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        //  print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
    }
    
}

