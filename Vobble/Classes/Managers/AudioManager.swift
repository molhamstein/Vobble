//
//  AudioManager.swift
//  Vobble
//
//  Created by Emessa Group on 11/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import JSQMessagesViewController


class AudioManager : NSObject {
    static let shared = AudioManager()
    
    var audioPlayer : AVAudioPlayer!
    var audioSession : AVAudioSession!
    var progressView : UIProgressView!
    var progressLabel : UILabel!
    var timer: Timer!
    var playButton: UIButton!
    
    func playAudio(data : Data, progressView: UIProgressView, progressLabel: UILabel, playButton: UIButton) {
        self.progressView = progressView
        self.progressLabel = progressLabel
        self.playButton = playButton
        
        self.progressView.progress = 0.0
        self.progressLabel.text = "00"
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1
            
            startTimer()
            audioPlayer.play()

        }catch{
            playButton.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
        }
        
        
    }
    
    func stopAudio() {
        audioPlayer.stop()
        playButton.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
        
    }
    
    func resumeAudio(){
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        startTimer()
        audioPlayer.play()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    
    func updateProgress() {
        if self.audioPlayer.isPlaying{
            self.progressLabel.text = String(format: "%02d", Int(self.audioPlayer.currentTime))
            self.progressView.progress = Float(self.audioPlayer.currentTime / self.audioPlayer.duration)
        }else{
            timer.invalidate()
            playButton.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            
        }
        
    }
}
