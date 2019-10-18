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
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var bottleNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timerLabel: TimerLabel!
    @IBOutlet weak var timeLeftTitleLabel: UILabel!
    @IBOutlet weak var ivNewMessageIcon: UIImageView!
    
    var shadowApplied: Bool! = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        chatButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        chatButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        chatButton.layer.shadowOpacity = 1.0
        chatButton.layer.shadowRadius = 7.0
        chatButton.layer.masksToBounds = false
        chatButton.layer.cornerRadius = chatButton.frame.height/2
        chatButton.layer.borderWidth = 0
        
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
    
    func configCell(convObj: Conversation) {
        
//        mainView.applyGradient(colours: [(convObj.user2?.firstColor)!, (convObj.user2?.secondColor)!], direction: .horizontal)
        
        if convObj.isMyBottle {
            bottleNameLabel.text = convObj.user?.userName
        } else {
            bottleNameLabel.text = convObj.bottle?.owner?.userName
        }
//        timeLabel.text = "Time left: "+convObj.timeLeft!
        countryLabel.text = convObj.getPeer?.country?.name
        
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
        
        // the unread mesages count for this conversation
        var unreadMessagesCount = 0
        if let convId = convObj.idString {
            if let messagesCount = DataStore.shared.conversationsMyBottlesUnseenMesssages[convId], messagesCount > 0 {
                unreadMessagesCount = messagesCount
            } else if let messagesCount = DataStore.shared.conversationsMyRepliesUnseenMesssages[convId], messagesCount > 0 {
                unreadMessagesCount = messagesCount
            }
        }
        
        if unreadMessagesCount > 0 {
            ivNewMessageIcon.isHidden = false
            wiggleAnimate(view: ivNewMessageIcon)
        } else {
            ivNewMessageIcon.isHidden = true
            ivNewMessageIcon.layer.removeAllAnimations()
        }
        
        weak var selfWeakRef = self
        dispatch_main_after(0.2) {
            if let selfRef = selfWeakRef, selfRef.shadowHolderView != nil && !selfRef.shadowApplied {
                selfRef.shadowHolderView.dropShortShadow()
                selfRef.shadowApplied = true
            }
        }
    }
    
    func wiggleAnimate(view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.3
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.autoreverses = true
        animation.fromValue = NSNumber(value: 0.98)
        animation.toValue = NSNumber(value: 1.07)
        //animation.fromValue = NSValue(cgPoint: CGPoint(x: 0.98, y: 0.98))
        //animation.toValue = NSValue(cgPoint: CGPoint(x: 1.05, y: 1.05))
        view.layer.add(animation, forKey: "transform.scale")
    }
    
}
