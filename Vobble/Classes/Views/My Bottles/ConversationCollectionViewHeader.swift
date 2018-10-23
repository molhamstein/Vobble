//
//  MyBottlesCollectionViewHeader.swift
//  Vobble
//
//  Created by Bayan on 3/14/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit


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
    // bottles thrown
    @IBOutlet weak var lblBottlesThrownCount: UILabel!
    @IBOutlet weak var lblBottlesThrownCountTitle: UILabel!
    
    @IBOutlet weak var lblUnreadMyBottlesConversationsBadge: UILabel!
    @IBOutlet weak var lblUnreadMyRepliesConversationsBadge: UILabel!
    
    public weak var convVC: ConversationViewController?
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        
        // wording 
        lblBottlesLeftCountTitle.text = "MY_BOTTLES_LEFT_TITLE".localized
        lblBottlesThrownCountTitle.text = "MY_BOTTLES_THROWN_TITLE".localized
        btnMyReplies.setTitle("MY_BOTTLES_REPLIES_TITLE".localized, for: .normal)
        btnMyBottles.setTitle("MY_BOTTLES_BOTTLES_TITLE".localized, for: .normal)
        lblNextRefillTitle.text = "MY_BOTTLES_NEXT_REFILL".localized
        
        // font
        lblBottlesLeftCountTitle.font = AppFonts.xSmall
        lblBottlesThrownCountTitle.font = AppFonts.xSmall
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
        
        lblUnreadMyBottlesConversationsBadge.isHidden = true
        lblUnreadMyRepliesConversationsBadge.isHidden = true
    }
    
    func configCell(userObj: AppUser) {
        userNameLabel.text = DataStore.shared.me?.userName
        lblBottlesLeftCount.text = "\(DataStore.shared.me?.totalBottlesLeftToThrowCount ?? 0)"
        lblBottlesThrownCount.text = "\(DataStore.shared.me?.thrownBottlesCount ?? 0)"
        
        if let nextRefillTime = DataStore.shared.me?.nextRefillDate {
            let currentDate = Date().timeIntervalSince1970
            lblNextRefillDate.startTimer(seconds: TimeInterval((nextRefillTime.timeIntervalSince1970 - currentDate)))
        } else {
            lblNextRefillDate.text = "-- : --"
        }
        
        // show count on bottles tabs
//        let bCount = DataStore.shared.myBottles.count
//        if  bCount > 0  {
//            btnMyBottles.setTitle(String.init(format: "MY_BOTTLES_BOTTLES_TITLE_With_count".localized, bCount), for: .normal)
//        } else {
//            btnMyBottles.setTitle("MY_BOTTLES_BOTTLES_TITLE".localized, for: .normal)
//        }
//        // replies
//        let rCount = DataStore.shared.myReplies.count
//        if rCount > 0 {
//            btnMyReplies.setTitle(String.init(format: "MY_BOTTLES_REPLIES_TITLE_With_count".localized, rCount), for: .normal)
//        } else {
//            btnMyReplies.setTitle("MY_BOTTLES_REPLIES_TITLE".localized, for: .normal)
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesCountChange), name: Notification.Name("unreadMessagesChange"), object: nil)
        self.unreadMessagesCountChange ()
    }
    
    @IBAction func myBottlesButtonPressed(_ sender: Any) {
        convVC?.refreshView()
        btnMyReplies.isSelected = false
        btnMyBottles.isSelected = true
        btnMyReplies.alpha = 0.5
        btnMyBottles.alpha = 1.0
    }
    
    @IBAction func MyRepliesButtonPressed(_ sender: Any) {
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
    
    func unreadMessagesCountChange () {
        // my replies
        let countReplies = DataStore.shared.getMyRepliesConversationsWithUnseenMessagesCount()
        if countReplies > 0{
            lblUnreadMyRepliesConversationsBadge.text = "\(countReplies)"
            lblUnreadMyRepliesConversationsBadge.isHidden = false
        } else {
            lblUnreadMyRepliesConversationsBadge.isHidden = true
        }
        
        // my bottles
        let countBottles = DataStore.shared.getMyBottlesConversationsWithUnseenMessagesCount()
        if countBottles > 0{
            lblUnreadMyBottlesConversationsBadge.text = "\(countBottles)"
            lblUnreadMyBottlesConversationsBadge.isHidden = false
        } else {
            lblUnreadMyBottlesConversationsBadge.isHidden = true
        }
        
    }
}

