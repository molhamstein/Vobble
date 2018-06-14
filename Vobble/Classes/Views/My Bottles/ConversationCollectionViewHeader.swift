//
//  MyBottlesCollectionViewHeader.swift
//  Vobble
//
//  Created by Bayan on 3/14/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

enum tapOption {
    case myBottles
    case myReplies
}

class ConversationCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var searchTetField: UITextField!
    @IBOutlet weak var btnMyBottles: UIButton!
    @IBOutlet weak var btnMyReplies: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageBtn: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // next refill
    @IBOutlet weak var lblNextRefillTitle: UILabel!
    @IBOutlet weak var lblNextRefillDate: TimerLabel!
    // bottles thrown
    @IBOutlet weak var lblBottlesLeftCount: UILabel!
    @IBOutlet weak var lblBottlesLeftCountTitle: UILabel!
    @IBOutlet weak var lblBottlesLeftCountSubTitle: UILabel!
    // bottles thrown
    @IBOutlet weak var lblBottlesThrownCount: UILabel!
    @IBOutlet weak var lblBottlesThrownCountTitle: UILabel!
    @IBOutlet weak var lblBottlesThrownCountSubTitle: UILabel!
    
    public var convVC: ConversationViewController?
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        
        // wording 
        lblBottlesLeftCountTitle.text = "MY_BOTTLES_LEFT_TITLE".localized
        lblBottlesLeftCountSubTitle.text = "MY_BOTTLES_LEFT_SUBTITLE".localized
        lblBottlesThrownCountTitle.text = "MY_BOTTLES_THROWN_TITLE".localized
        lblBottlesThrownCountSubTitle.text = "MY_BOTTLES_THROWN_SUBTITLE".localized
        btnMyReplies.setTitle("MY_BOTTLES_REPLIES_TITLE".localized, for: .normal)
        btnMyBottles.setTitle("MY_BOTTLES_BOTTLES_TITLE".localized, for: .normal)
        lblNextRefillTitle.text = "MY_BOTTLES_NEXT_REFILL".localized
        
        // font
        lblBottlesLeftCountTitle.font = AppFonts.xSmall
        lblBottlesLeftCountSubTitle.font = AppFonts.xSmall
        lblBottlesThrownCountTitle.font = AppFonts.xSmall
        lblBottlesThrownCountSubTitle.font = AppFonts.xSmall
        btnMyReplies.titleLabel?.font = AppFonts.bigBold
        btnMyBottles.titleLabel?.font = AppFonts.bigBold
        lblNextRefillTitle.font = AppFonts.xSmall
        lblNextRefillDate.font = AppFonts.xSmall
        
        self.activityIndicator.isHidden = true
        btnMyBottles.isSelected = true
        
        if let imgUrl = DataStore.shared.me?.profilePic, imgUrl.isValidLink() {
            userImageView.sd_setShowActivityIndicatorView(true)
            userImageView.sd_setIndicatorStyle(.gray)
            userImageView.sd_setImage(with: URL(string: imgUrl))
        } else {
            userImageView.image = UIImage(named:"user_placeholder")
        }
    }
    
    func configCell(userObj: AppUser) {
        userNameLabel.text = DataStore.shared.me?.userName
        lblBottlesLeftCount.text = "\(DataStore.shared.me?.bottlesLeftToThrowCount ?? 0)"
        lblBottlesThrownCount.text = "\(DataStore.shared.me?.bottlesCount ?? 0)"
        
        if let nextRefillTime = DataStore.shared.me?.nextRefillDate{
            let currentDate = Date().timeIntervalSince1970
            lblNextRefillDate.startTimer(seconds: TimeInterval((nextRefillTime.timeIntervalSince1970 - currentDate)))
        } else {
            lblNextRefillDate.text = "-- : --"
        }
    }
    
    @IBAction func myBottlesButtonPressed(_ sender: Any) {
        convVC?.tap = .myBottles
        convVC?.refreshView()
        btnMyReplies.isSelected = false
        btnMyBottles.isSelected = true
        btnMyReplies.alpha = 0.5
        btnMyBottles.alpha = 1.0
    }
    
    @IBAction func MyRepliesButtonPressed(_ sender: Any) {
        convVC?.tap = .myReplies
        convVC?.refreshView()
        btnMyReplies.isSelected = true
        btnMyBottles.isSelected = false
        btnMyReplies.alpha = 1.0
        btnMyBottles.alpha = 0.5
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        convVC?.performSegue(withIdentifier: "conversationsSettingsSegue", sender: convVC)
    }
    
    @IBAction func setUserImageBtnPressed(_ sender: Any) {
        
        convVC?.imgLoading = self.activityIndicator
        convVC?.userImageView = self.userImageView
        convVC?.setUserImage()
        
    }
}

