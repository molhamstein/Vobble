//
//  FindBottleViewController.swift
//  Vobble
//
//  Created by BrainSocet on 18/4/28.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView
import Firebase
import Flurry_iOS_SDK
import WCLShineButton
import CountryPickerView

class FindBottleViewController: AbstractController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shoreNameLabel: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var moreOptionsOverlayButton: UIButton!
    
    @IBOutlet var videoView: VideoPlayerView!
    
    @IBOutlet weak var ignoreButton: VobbleButton!
    @IBOutlet weak var replyButton: WCLShineButton!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    public var bottle:Bottle?
    public var shoreName:String?
    public var myVideoUrl : NSURL?
    public var myAudioUrl : URL?
    
    @IBOutlet weak var optionView: UIStackView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportPicker: UIPickerView!
    
    var isInitialized = false
    
    fileprivate var reportReasonIndex: Int = 0
    fileprivate var countryPickerView: CountryPickerView = CountryPickerView()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        shoreNameLabel.text = bottle?.shore?.name
        userNameLabel.text = bottle?.owner?.userName
        countryFlag.image = countryPickerView.getCountryByName(bottle?.owner?.country?.nameEn ?? "")?.flag
        genderImage.image = bottle?.owner?.gender == .male ? UIImage(named: "signup_male") : UIImage(named: "signup_female")
        videoView.preparePlayer(videoURL: bottle?.attachment ?? "", customPlayBtn: playButton)
        optionView.isHidden = true
        moreOptionsOverlayButton.isHidden = true
        reportView.isHidden = true
        reportButton.setTitle("REPORT".localized, for: .normal)
        blockButton.setTitle("BLOCK_USER".localized, for: .normal)
        ignoreButton.setTitle("IGNORE".localized, for: .normal)
        //replyButton.setTitle("REPLY".localized, for: .normal)
        
        // round flag image view
        countryFlag.layer.cornerRadius = 12
        countryFlag.layer.masksToBounds = true
        
        if let imgUrl = bottle?.owner?.profilePic, imgUrl.isValidLink() {
            userimage.sd_setShowActivityIndicatorView(true)
            userimage.sd_setIndicatorStyle(.gray)
            userimage.sd_setImage(with: URL(string: imgUrl))
        }
        
        // Reply button animation setup
        var parameters = WCLShineParams()
        parameters.bigShineColor = AppColors.blueXLight
        parameters.animDuration = 2
        replyButton.image = .defaultAndSelect(#imageLiteral(resourceName: "replay_circle"), #imageLiteral(resourceName: "replay_circle"))
        replyButton.params = parameters

        // a workarround that I'm not sure of it yet to resolve the issue of the video sound comming from the ear speaker sometimes
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSessionCategoryPlayback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialized == false {
            topView.applyGradient(colours: [AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
            //bottomView.applyGradient(colours: [AppColors.blackXLightWithAlpha, AppColors.blackXDarkWithAlpha], direction: .vertical)
            ignoreButton.applyGradient(colours: [AppColors.grayXLight, AppColors.grayDark], direction: .horizontal)
            //replyButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
            replyLabel.text = "REPLY".localized
            
            // show chat tutorial on first opening of an unblocked chat
            if let tutShowedBefore = DataStore.shared.me?.replyTutShowed, !tutShowedBefore {
                DataStore.shared.me?.replyTutShowed = true
                dispatch_main_after(2) {
                    DataStore.shared.me?.replyTutShowed = true
                    let viewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ReplyTutorial") as! ReplyTutorialViewController
                    viewController.alpha = 0.5
                    viewController.buttonFrame = self.replyButton.superview?.convert(self.replyButton.frame, to: nil)
                    viewController.findViewController = self
                    self.present(viewController, animated: true, completion: nil)
                    if let me = DataStore.shared.me {
                        ApiManager.shared.updateUser(user: me) { (success: Bool, err: ServerError?, user: AppUser?) in }
                    }
                    // hide the tutorial automatically after 3 seconds
                    dispatch_main_after(3) {
                        if let _ = viewController.view.window, viewController.isViewLoaded {
                           viewController.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            
            // mark the video as seen after the user has watched 4 seconds of it
            dispatch_main_after(4) {
                if let bottleObj = self.bottle {
                    // make sure the vie controller is still open after 4 seconds
                    if let _ = self.view.window, self.isViewLoaded {
                        ApiManager.shared.markBottleSeen(bottle: bottleObj, completionBlock: { (success, err) in })
                    }
                }
            }
            
            isInitialized = true
        }
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreOptionBtnPressed(_ sender: Any) {
        if optionView.isHidden == true {
            optionView.isHidden = false
            moreOptionsOverlayButton.isHidden = false
        } else {
            optionView.isHidden = true
            moreOptionsOverlayButton.isHidden = true
        }
    }
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        if self.videoView.isPlaying() {
            videoView.playButtonPressed()
        }
        reportView.isHidden = false
        optionView.isHidden = true
    }
    
    @IBAction func blockBtnPressed(_ sender: Any) {
        if self.videoView.isPlaying() {
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
        let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
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
        
        if videoView.isPlaying() {
            videoView.playButtonPressed()
        }
        
//        // show record Video screen
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // delay 6 second
//            let recordControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RecordMediaViewControllerID") as! RecordMediaViewController
//            recordControl.from = .findBottle
//
//            self.navigationController?.pushViewController(recordControl, animated: false)
//        }
        
        // show record Audio screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // delay 6 second
            let recordControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RecordAudioReplyMediaControlID") as! RecordAudioReplyMediaControl
            
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
            chatVc.replyVideoUrlToUpload = myVideoUrl as URL?
            chatVc.replyAudioUrlToUpload = myAudioUrl
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if !self.videoView.isPlaying() {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
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
        if let btl = self.bottle {
            FirebaseManager.shared.createNewConversation(bottle: btl, completionBlock: { (err, databaseReference) in
                if let _ = err {
                    self.showMessage(message: ServerError.unknownError.type.errorMessage, type: .error)
                } else {
                    self.showActivityLoader(false)
                    ApiManager.shared.replyToBottle(bottle: btl, completionBlock: { (success, err) in })
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
