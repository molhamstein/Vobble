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
    
    var shadowApplied: Bool! = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        // mainView.dropShadow()
        chatButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
        mainView.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        dispatch_main_after(2.2) {
//            self.mainView.dropShadow()
//        }
    }
    
    func configCell(convObj: Conversation,tap: tapOption) {
        
        //        mainView.dropShadow()
//        mainView.applyGradient(colours: [(convObj.user2?.firstColor)!, (convObj.user2?.secondColor)!], direction: .horizontal)
        
        if tap == .myBottles {
            bottleNameLabel.text = convObj.bottle?.owner?.firstName
        } else {
            bottleNameLabel.text = convObj.user?.firstName
        }
//        timeLabel.text = "Time left: "+convObj.timeLeft!
//        countryLabel.text = convObj.user2?.country
//        image.image = convObj.user2?.imageUrl
        
        if let fTime = convObj.finishTime {
            let currentDate = Int(Date().timeIntervalSince1970 * 1000)
            timerLabel.startTimer(seconds: TimeInterval((Int(fTime) - currentDate)/1000))
        }
        
        dispatch_main_after(0.2) {
            if !self.shadowApplied {
                self.shadowHolderView.dropShortShadow()
                self.shadowApplied = true
            }
        }
    }
    
}
