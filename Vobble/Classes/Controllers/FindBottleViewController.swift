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
import Flurry_iOS_SDK

class FindBottleViewController: AbstractController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shoreNameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var userimage: UIImageView!
    
    @IBOutlet var videoView: VideoPlayerView!
    
    @IBOutlet weak var ignoreButton: VobbleButton!
    @IBOutlet weak var replyButton: VobbleButton!
    @IBOutlet weak var playButton: UIButton!
    
    public var bottle:Bottle?
    public var shoreName:String?
    public var myVideoUrl = NSURL()
    
    @IBOutlet weak var optionView: UIStackView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportPicker: UIPickerView!
    
    var isInitialized = false
    
    fileprivate var reportReasonIndex:Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        shoreNameLabel.text = shoreName
        userNameLabel.text = bottle?.owner?.userName
        videoView.preparePlayer(videoURL: bottle?.attachment ?? "", customPlayBtn: nil)
        optionView.isHidden = true
        reportView.isHidden = true
        reportButton.setTitle("REPORT".localized, for: .normal)
        blockButton.setTitle("BLOCK_USER".localized, for: .normal)
        ignoreButton.setTitle("IGNORE".localized, for: .normal)
        replyButton.setTitle("REPLY".localized, for: .normal)
        
        if let imgUrl = bottle?.owner?.profilePic, imgUrl.isValidLink() {
            userimage.sd_setShowActivityIndicatorView(true)
            userimage.sd_setIndicatorStyle(.gray)
            userimage.sd_setImage(with: URL(string: imgUrl))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialized == false {
            topView.applyGradient(colours: [AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
            //bottomView.applyGradient(colours: [AppColors.blackXLightWithAlpha, AppColors.blackXDarkWithAlpha], direction: .vertical)
            ignoreButton.applyGradient(colours: [AppColors.grayXLight, AppColors.grayDark], direction: .horizontal)
            replyButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
            isInitialized = true
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreOptionBtnPressed(_ sender: Any) {
        if optionView.isHidden == true {
            optionView.isHidden = false
        } else {
            optionView.isHidden = true
        }
    }
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        if self.playButton.currentImage == UIImage(named: "pause") {
            videoView.playButtonPressed()
        }
        reportView.isHidden = false
        optionView.isHidden = true
    }
    
    @IBAction func blockBtnPressed(_ sender: Any) {
        if self.playButton.currentImage == UIImage(named: "pause") {
            videoView.playButtonPressed()
        }
        
        let blockMessage = String(format: "BLOCK_USER_WARNING".localized, "\(self.bottle?.owner?.userName ?? " ")")
        
        let alertController = UIAlertController(title: "", message: blockMessage , preferredStyle: .alert)
        //We add buttons to the alert controller by creating UIAlertActions:
        let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
            //self.dismiss(animated: true, completion: nil)
            // here send block to server
            if let bottleOwner = self.bottle?.owner {
                self.showActivityLoader(true)
                ApiManager.shared.blockUser(user: bottleOwner, completionBlock: { (success, err) in
                    self.showActivityLoader(false)
                    if err == nil {
                        let blockMessage = String(format: "BLOCK_USER_SUCCESS".localized, "\(bottleOwner.userName ?? " ")")
                        let alertController = UIAlertController(title: "", message: blockMessage , preferredStyle: .alert)
                        let ok = UIAlertAction(title: "ok".localized, style: .default, handler:{(alertAction) in self.dismiss(animated: true, completion: nil)} )
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "", message: err?.type.errorMessage, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
            
        })
        alertController.addAction(ok)
        let cancel = UIAlertAction(title: "cancel".localized, style: .default,  handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        reportView.isHidden = true
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        print(self.reportReasonIndex)
        reportView.isHidden = true
        if let bottle = self.bottle {
            ApiManager.shared.reportBottle(bottle: bottle, reportType: DataStore.shared.reportTypes[self.reportReasonIndex], completionBlock: { (success, error) in
                if success {
                    let alertController = UIAlertController(title: "", message: "REPORT_SUCCESS_MSG".localized, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok".localized, style: .default, handler:{(alertAction) in self.dismiss(animated: true, completion: nil)} )
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "", message: "ERROR_NO_CONNECTION".localized, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func replyBtnPressed(_ sender: Any) {
        
        let logEventParams = ["Shore": shoreName ?? "", "AuthorGender": (bottle?.owner?.gender?.rawValue) ?? "", "AuthorCountry": (bottle?.owner?.countryISOCode) ?? ""];
        Flurry.logEvent(AppConfig.reply_pressed, withParameters:logEventParams);
        
        if self.playButton.currentImage == UIImage(named: "pause") {
            videoView.playButtonPressed()
        }
        
        // show preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // delay 6 second
            let recordControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RecordMediaViewControllerID") as! RecordMediaViewController
            recordControl.from = .findBottle
            
            self.navigationController?.pushViewController(recordControl, animated: false)
        }

    }
    
    @IBAction func ignoreBtnPressed(_ sender: Any) {
        let logEventParams :[String : String] = ["Shore": shoreName ?? "", "AuthorGender": (bottle?.owner?.gender?.rawValue) ?? "", "AuthorCountry": (bottle?.owner?.countryISOCode) ?? ""];
        Flurry.logEvent(AppConfig.reply_ignored, withParameters:logEventParams);
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let newConvRef = sender as? DatabaseReference, let btl = bottle {
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
            chatVc.senderDisplayName = DataStore.shared.me?.userName
            chatVc.conversationRef = newConvRef
            chatVc.conversationId = newConvRef.key
            chatVc.bottleToReplyTo = btl
            chatVc.replyVideoUrlToUpload = myVideoUrl as URL
            
//            chatVc.conversation = conversation
//            chatVc.conversationRef = conversationRef.child("-L86Uca5m1JySQFqoqWP")
//            chatVc.uploadMedia(mediaReferenceUrl: bottle?.attachment!, mediaType: "public.movie", senderId: "\(bottle?.ownerId)")
            
          
//            if let bottleOwnerId = bottle?.ownerId {
//                chatVc.senderId = "\(bottleOwnerId)"
//                chatVc.uploadMedia(mediaReferenceUrl: self.myVideoUrl as URL, mediaType: "public.movie", senderId: "\(bottleOwnerId)")
//            }
            
//            if let uid = DataStore.shared.me?.objectId {
//                chatVc.senderId = "\(uid)"
//                chatVc.uploadMedia(mediaReferenceUrl: self.myVideoUrl as URL, mediaType: "public.movie", senderId: "\(uid)")
//            }

//            chatVc.seconds = 24.0*60.0*60.0

            
            ////////////
//            if let btl = bottle, let bottleOwnerId = btl.ownerId, let url = btl.attachment, let thumbUrl = btl.thumb {
//                chatVc.senderId = "\(bottleOwnerId)"
//                chatVc.submitMessageWithVideoURL(videoUrl: url, thumbURL: thumbUrl)
//
//                //send push notification to bottle owner to inform him about the new reply
//                if let peer = btl.owner {
//                    let msgToSend = String(format: "NOTIFICATION_NEW_REPLY".localized, (DataStore.shared.me?.userName)!)
//                    ApiManager.shared.sendPushNotification(msg: msgToSend, targetUser: peer, completionBlock: { (success, error) in })
//                }
//            }
//
//            if let myId = DataStore.shared.me?.objectId {
//                chatVc.senderId = "\(myId)"
//                chatVc.uploadVideo(videoUrl: self.myVideoUrl as URL)
//            }
//
//            chatVc.isHideInputToolBar = true
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
        
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           self.goToChat()
       }
    }
    
    func goToChat() {
//
//
//        let newConvRef = self.conversationRef.childByAutoId()
//
//        let convlItem:[String : Any] = [
//            "bottle": (self.bottle?.dictionaryRepresentation()) ?? "",
//            "user": (DataStore.shared.me?.dictionaryRepresentation()) ?? "",
//            "createdAt" : ServerValue.timestamp(),
//            "is_seen" : 0,
//            "startTime" : 0.0
//        ]
//
//        self.showActivityLoader(true)
//        newConvRef.setValue(convlItem) { (err, convReference) in
//
//        }
        
        if let btl = self.bottle {
            FirebaseManager.shared.createNewConversation(bottle: btl, completionBlock: { (err, databaseReference) in
                if let error = err {
                    self.showMessage(message: ServerError.unknownError.type.errorMessage, type: .error)
                } else {
                    self.showActivityLoader(false)
                    self.performSegue(withIdentifier: "goToChat", sender: databaseReference)
                    
                }
            })
        }
    }
}

extension FindBottleViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    private var pickerArray: [ReportType] {
        get {
           return DataStore.shared.reportTypes
        }
    }
    
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    public func pickerView(_pickerView:UIPickerView,numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.reportReasonIndex = row
        print(pickerArray[row])
    }
}
