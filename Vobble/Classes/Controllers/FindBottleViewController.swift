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
    
    public var bottle:Bottle?
    public var myVideoUrl = NSURL()
    
    // MARK: - firebase Properties
    fileprivate var conversationRefHandle: DatabaseHandle?
    
    
    fileprivate lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")

//    private lazy var user1Ref: DatabaseReference = self.conversationRef.child("user1")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        videoView.preparePlayer(videoURL: bottle?.attachment ?? "", customPlayBtn: playButton)
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
        
        // show preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // delay 6 second
            let recordControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RecordMediaViewControllerID") as! RecordMediaViewController
            recordControl.from = .findBottle
            
            self.navigationController?.pushViewController(recordControl, animated: false)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        if let newConvRef = sender as? DatabaseReference {
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
            chatVc.senderDisplayName = DataStore.shared.me?.firstName
//            chatVc.conversation = conversation
//            chatVc.conversationRef = conversationRef.child("-L86Uca5m1JySQFqoqWP")
//            chatVc.uploadMedia(mediaReferenceUrl: bottle?.attachment!, mediaType: "public.movie", senderId: "\(bottle?.ownerId)")
            chatVc.conversationRef = newConvRef
          
//            if let bottleOwnerId = bottle?.ownerId {
//                chatVc.senderId = "\(bottleOwnerId)"
//                chatVc.uploadMedia(mediaReferenceUrl: self.myVideoUrl as URL, mediaType: "public.movie", senderId: "\(bottleOwnerId)")
//            }
            
//            if let uid = DataStore.shared.me?.objectId {
//                chatVc.senderId = "\(uid)"
//                chatVc.uploadMedia(mediaReferenceUrl: self.myVideoUrl as URL, mediaType: "public.movie", senderId: "\(uid)")
//            }

            if let uid = DataStore.shared.me?.objectId {
                chatVc.senderId = "\(uid)"
                chatVc.uploadVideo(videoUrl: self.myVideoUrl as URL)
            }
            
            if let bottleOwnerId = bottle?.ownerId {
                chatVc.senderId = "\(bottleOwnerId)"
                chatVc.uploadVideo(videoUrl: self.myVideoUrl as URL)
            }
        }
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if self.playButton.currentImage == UIImage(named: "ic_play") {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else if self.playButton.currentImage == UIImage(named: "pause") {
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        }
        videoView.playButtonPressed()
    }
    
    @IBAction func unwindToFindBottle(segue: UIStoryboardSegue) {
        
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // delay 6 second
           self.goToChat()
       }
    }
    
    func goToChat() {

        let newConvRef = self.conversationRef.childByAutoId()
        let convlItem:[String : Any] = [
            "bottle": self.bottle?.dictionaryRepresentation(),
            "user": DataStore.shared.me?.dictionaryRepresentation()
        ]
        
        newConvRef.setValue(convlItem)
        
        self.performSegue(withIdentifier: "goToChat", sender: newConvRef)
        }
}
