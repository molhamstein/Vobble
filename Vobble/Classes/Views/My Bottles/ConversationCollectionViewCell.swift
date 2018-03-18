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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatButton: VobbleButton!
    @IBOutlet weak var bottleNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var shadowApplied: Bool! = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        // mainView.dropShadow()
        chatButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        dispatch_main_after(2.2) {
//            self.mainView.dropShadow()
//        }
    }
    
    func configCell(convObj: Conversation) {
        
        //        mainView.dropShadow()
        mainView.applyGradient(colours: [(convObj.user2?.firstColor)!, (convObj.user2?.secondColor)!], direction: .horizontal)
        bottleNameLabel.text = convObj.user2?.firstName
        timeLabel.text = "Time left: "+convObj.timeLeft!
        countryLabel.text = convObj.user2?.country
        image.image = convObj.user2?.imageUrl
        
        dispatch_main_after(0.2) {
            if !self.shadowApplied {
                self.shadowHolderView.dropShortShadow()
                self.shadowApplied = true
            }
        }
    }
    
}
