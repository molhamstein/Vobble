//
//  TimerLabel.swift
//  Vobble
//
//  Created by Bayan on 3/24/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit

@objc protocol TimerLabelDelegate {
    
    @objc optional func timerFinished()
    @objc optional func countingAt(timeRemaining: TimeInterval)
    @objc optional func conversationWillEnd()
}


class TimerLabel: UILabel {
    
//    @IBOutlet weak var timerLabel: UILabel!
    
    // MARK: - properties
    private var seconds = 0
    private var shakerResetTime = 5
    private var extendChatShouldFire = 60 * 60 * 8 // When there is only 8 hours left
    private var timer = Timer()
    private var isTimerRunning = false
    private var resumeTapped = false
    public weak var delegate:TimerLabelDelegate?
    
    
    func startTimer(seconds:TimeInterval) {
        self.seconds = Int(seconds)
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    func pauseTimer() {
        if self.resumeTapped == false {
            timer.invalidate()
            self.resumeTapped = true
        } else {
            runTimer()
            self.resumeTapped = false
        }
    }
    
    func resetTimer(seconds:TimeInterval) {
        timer.invalidate()
//        timerLabel.text = timeString(time: TimeInterval(seconds))
        text = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
    }
    
    private func runTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate "time's up!"
            delegate?.countingAt?(timeRemaining: TimeInterval(0))
        } else {
            seconds -= 1
            
            // call 'conversationWillEnd' when only 8 hours left
            if seconds <= extendChatShouldFire  {
                if shakerResetTime == 0 {
                    delegate?.conversationWillEnd?()
                    shakerResetTime = 5
                }else {
                    shakerResetTime -= 1
                }
            }
            
            text = timeString(time: TimeInterval(seconds))
            
            delegate?.countingAt?(timeRemaining: TimeInterval(seconds))
        }
    }
    
    private func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    
}
