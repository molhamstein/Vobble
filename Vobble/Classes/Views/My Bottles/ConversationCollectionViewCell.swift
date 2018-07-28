//
//  MyBottlesViewCell.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit


class ConversationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowHolderView: UIView!
    @IBOutlet weak var chatButton: VobbleButton!
    @IBOutlet weak var bottleNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timerLabel: TimerLabel!
    @IBOutlet weak var timeLeftTitleLabel: UILabel!
    
    var shadowApplied: Bool! = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        chatButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
        //mainView.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
        
        timeLeftTitleLabel.font = AppFonts.normalBold
        timerLabel.font = AppFonts.normalBold
        chatButton.titleLabel?.font = AppFonts.normalBold
        
        chatButton.setTitle("MY_BOTTLES_BTN_CHAT".localized, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(convObj: Conversation,tap: tapOption) {
        
//        mainView.applyGradient(colours: [(convObj.user2?.firstColor)!, (convObj.user2?.secondColor)!], direction: .horizontal)
        
        if tap == .myBottles {
            bottleNameLabel.text = convObj.user?.userName
        } else {
            bottleNameLabel.text = convObj.bottle?.owner?.userName
        }
//        timeLabel.text = "Time left: "+convObj.timeLeft!
//        countryLabel.text = convObj.user2?.country
        
        if let peerImage = convObj.getPeer?.profilePic, peerImage.isValidLink() == true {
            image.sd_setImage(with: URL(string:peerImage))
        } else {
            image.image = UIImage(named:"user_placeholder")
        }
        
        if let fTime = convObj.finishTime {
            let currentDate = Date().timeIntervalSince1970 * 1000
            timerLabel.startTimer(seconds: TimeInterval((fTime - currentDate)/1000.0))
            timeLeftTitleLabel.text = "MY_BOTTLES_TIME_LEFT".localized
        } else {
            timerLabel.resetTimer(seconds: 0)
            if convObj.isMyBottle {
                timerLabel.text = "MY_BOTTLES_YOU_DIDNT_REPLY_YET".localized
            } else {
                timerLabel.text = String.init(format: "MY_BOTTLES_PEER_DIDNT_REPLY_YET".localized, convObj.getPeer?.userName ?? "")
            }
            timeLeftTitleLabel.text = ""
        }
        
        if convObj.isMyBottle {
            chatButton.isEnabled = true
        } else {
            if let seen = convObj.is_seen, seen >= 1 {
                chatButton.isEnabled = true
            }else {
                chatButton.isEnabled = false
            }
        }
        
        dispatch_main_after(0.2) {
            if !self.shadowApplied {
                self.shadowHolderView.dropShortShadow()
                self.shadowApplied = true
            }
        }
    }
    
}
