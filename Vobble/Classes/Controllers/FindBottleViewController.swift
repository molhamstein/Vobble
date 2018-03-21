//
//  FindBottleViewController.swift
//  BMPlayer
//
//  Created by BrikerMan on 16/4/28.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import BMPlayer
import AVFoundation
import NVActivityIndicatorView
import Firebase

class FindBottleViewController: AbstractController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet var videoView: VideoPlayerView!
    
    @IBOutlet weak var ignoreButton: VobbleButton!
    @IBOutlet weak var replyButton: VobbleButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - firebase Properties
    fileprivate var conversationRefHandle: DatabaseHandle?
    
    fileprivate lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")

//    private lazy var user1Ref: DatabaseReference = self.conversationRef.child("user1")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        videoView.preparePlayer(videoURL: "http://twigbig.com/vidoes/desktop.mp4",customPlayBtn: playButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topView.applyGradient(colours: [AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
        bottomView.applyGradient(colours: [AppColors.blackXLightWithAlpha, AppColors.blackXDarkWithAlpha], direction: .vertical)
        ignoreButton.applyGradient(colours: [AppColors.grayXLight, AppColors.grayDark], direction: .horizontal)
        replyButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    var newConvRef:DatabaseReference?
    
    @IBAction func replyBtnPressed(_ sender: Any) {
        
//        let newConvRef = conversationRef.childByAutoId()
//        let convlItem = [
//            "bottle_id": "bottle_1",
//            "user1_id": DataStore.shared.me?.id,
//            "user1_name": DataStore.shared.me?.firstName,
//            "user2_id": "1",
//            "user2_name": "bayan"
//        ]
        //==================
//        let user1 = [
//            "id": DataStore.shared.me?.id,
//            "username": DataStore.shared.me?.firstName,
//            "country": "Syria"
//        ]
//        let user2 = [
//            "id": "1",
//            "username": "koko koko",
//            "country": "USA"
//        ]
    //-----
//        newConvRef.setValue(convlItem)
    
//        newConvRef.child("user1").childByAutoId().setValue(user1)
//
//        newConvRef.child("user2").childByAutoId().setValue(user2)
        
        self.performSegue(withIdentifier: "goToChat", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
//        if let newConvRef = sender as? DatabaseReference {
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
        
//            let chatVc = segue.destination as! ChatViewController
        
            chatVc.senderDisplayName = DataStore.shared.me?.firstName
//            chatVc.conversation = conversation
            chatVc.conversationRef = conversationRef.child("-L86Uca5m1JySQFqoqWP")
//            chatVc.conversationRef = newConvRef
//        }
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if self.playButton.currentImage == UIImage(named: "ic_play") {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else if self.playButton.currentImage == UIImage(named: "pause") {
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        }
        videoView.playButtonPressed()
    }
    
}
