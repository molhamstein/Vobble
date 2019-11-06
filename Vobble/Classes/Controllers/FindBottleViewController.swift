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
import TransitionButton

class FindBottleViewController: AbstractController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shoreNameLabel: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var moreOptionsOverlayButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet var videoView: VideoPlayerView!
    
    //@IBOutlet weak var ignoreButton: VobbleButton!
    @IBOutlet weak var replyButton: WCLShineButton!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var playButton: TransitionButton!
    @IBOutlet weak var slideBar: UISlider!

    @IBOutlet weak var optionView: UIStackView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportPicker: UIPickerView!
    
    @IBOutlet weak var lblFilterTitle: UILabel!
    @IBOutlet weak var btnGenderFilter: UIButton!
    //@IBOutlet weak var btnCountryFilter: UIButton!
    @IBOutlet weak var filterView: FilterView!
    @IBOutlet weak var filterViewOverlay: UIView!
    
    fileprivate var displayNoContentMsg: Bool = false
    fileprivate var reportReasonIndex:Int = 0
    fileprivate var videoCards: [VideoPlayerLayer?] = []
    fileprivate var currentVideoCard: VideoPlayerLayer?
    fileprivate var nextVideoCard: VideoPlayerLayer?
    fileprivate var currentIndex: CGFloat = 0.0
    fileprivate var fixedIndex: Int = 0
    fileprivate var lastVelocityYSign = 0
    fileprivate var seen: [String]?
    fileprivate var complete: [String]?
    fileprivate var countryPickerView: CountryPickerView = CountryPickerView()
    
    public var currentBottle:Bottle?
    public var bottles:[Bottle]?
    public var shoreName:String?
    public var myVideoUrl : NSURL?
    public var myAudioUrl : URL?
    public var gender: GenderType = .allGender
    public var countryCode: String!
    public var shoreId: String?
    public var currentShoreIndex: Int = 0
    
    var isInitialized = false
    var isNextCardCreated: Bool = false
    var isGoingToSubViewController: Bool = false
    var shouldSetupScrollView: Bool = true
    var didCancelBuffering: Bool = false
    var isGettingVideos: Bool = false
    var filterViewVisible = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if bottles?.count ?? 0 > 0 {
            self.currentBottle = bottles?[0]
        }
        
        setupVideoData()
        
        optionView.isHidden = true
        moreOptionsOverlayButton.isHidden = true
        reportView.isHidden = true
        reportButton.setTitle("REPORT".localized, for: .normal)
        blockButton.setTitle("BLOCK_USER".localized, for: .normal)
        btnGenderFilter.setTitle("GENDER_AND_COUNTRY_FILTER".localized, for: .normal)
        //btnCountryFilter.setTitle("COUNTRY_FILTER".localized, for: .normal)
        lblFilterTitle.text = "FILTER_BY_TITLE".localized
        
        //ignoreButton.setTitle("IGNORE".localized, for: .normal)
        //replyButton.setTitle("REPLY".localized, for: .normal)
        //ignoreButton.titleLabel?.font = AppFonts.normalBold
        replyLabel.font = AppFonts.normalBold
        btnGenderFilter.titleLabel?.font = AppFonts.smallSemiBold
        //btnCountryFilter.titleLabel?.font = AppFonts.smallSemiBold
        lblFilterTitle.font = AppFonts.normal
        
        // round flag image view
        countryFlag.layer.cornerRadius = 12
        countryFlag.layer.masksToBounds = true
   
        // Reply button animation setup
        var parameters = WCLShineParams()
        parameters.bigShineColor = AppColors.blueXLight
        parameters.animDuration = 2
        replyButton.image = .defaultAndSelect(#imageLiteral(resourceName: "replay_circle"), #imageLiteral(resourceName: "replay_circle"))
        replyButton.params = parameters
        
        // inisialize filter view
        self.filterView.delegate = self
        self.filterView.relatedVC = self
        self.filterView.isHidden = true
        self.filterView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.filterView.frame.height - 50)
        self.filterViewOverlay.alpha = 0.0
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isGoingToSubViewController {
            isGoingToSubViewController = false
            scrollView.contentOffset = CGPoint(x: 0, y: Int(self.currentVideoCard?.frame.height ?? 0.0) * Int(self.currentIndex))
        }else {
            if shouldSetupScrollView {
                setupScrollView()
            }
        }
        
        // To make sure there is no other sound is playing
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeMoviePlayback, options: .mixWithOthers)
            } else {
                // Fallback on earlier versions
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /// MARK:- This block of code to make sure that all video player
        
        if !isGoingToSubViewController {
            if !didCancelBuffering {
                currentVideoCard?.cancelBuffring()
                nextVideoCard?.cancelBuffring()
                didCancelBuffering = true
            }
        }else { 
            currentVideoCard?.stop()
            nextVideoCard?.stop()
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialized == false {
            topView.applyGradient(colours: [AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
            //bottomView.applyGradient(colours: [AppColors.blackXLightWithAlpha, AppColors.blackXDarkWithAlpha], direction: .vertical)
            //ignoreButton.applyGradient(colours: [AppColors.grayXLight, AppColors.grayDark], direction: .horizontal)
            //replyButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
            //btnCountryFilter.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .vertical)
            btnGenderFilter.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .vertical)
            replyLabel.text = "REPLY".localized
            
            // show chat tutorial on first opening of an unblocked chat
            if let tutShowedBefore = DataStore.shared.me?.replyTutShowed, !tutShowedBefore {
                DataStore.shared.me?.replyTutShowed = true
                dispatch_main_after(2) {
                    DataStore.shared.me?.replyTutShowed = true
                    let viewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ReplyTutorial") as! ReplyTutorialViewController
                    viewController.alpha = 0.5
                    viewController.replyButtonFrame = self.replyButton.superview?.convert(self.replyButton.frame, to: nil)
                    viewController.closeButtonFrame = self.closeButton.superview?.convert(self.closeButton.frame, to: nil)
                    viewController.findViewController = self
                    self.isGoingToSubViewController = true
                    self.present(viewController, animated: true, completion: nil)
                    if let me = DataStore.shared.me {
                        ApiManager.shared.updateUser(user: me) { (success: Bool, err: ServerError?, user: AppUser?) in }
                    }
                    // hide the tutorial automatically after 3 seconds
//                    dispatch_main_after(3) {
//                        if let _ = viewController.view.window, viewController.isViewLoaded {
//                           viewController.dismiss(animated: true, completion: nil)
//                        }
//                    }
                }
            }
            
            isInitialized = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let newConvRef = sender as? DatabaseReference, let btl = currentBottle {
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
            chatVc.senderDisplayName = DataStore.shared.me?.userName
            chatVc.conversationRef = newConvRef
            chatVc.conversationId = newConvRef.key
            chatVc.bottleToReplyTo = btl
            chatVc.replyVideoUrlToUpload = myVideoUrl as URL?
            chatVc.replyAudioUrlToUpload = myAudioUrl
            isGoingToSubViewController = false
            shouldSetupScrollView = false
        }
    }

}

// MARK:- ScrollView Delegate
extension FindBottleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
        let currentVelocityYSign = Int(currentVelocityY).signum()
        
        if currentVelocityYSign != lastVelocityYSign &&
            currentVelocityYSign != 0 {
            lastVelocityYSign = currentVelocityYSign
        }
        
        // If scrolling to top so keep me in the same point
        if lastVelocityYSign > 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: UIScreen.main.bounds.height * self.currentIndex)
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.y/view.frame.height)
        print("page index is: \(pageIndex)")
        if pageIndex != currentIndex {
            currentIndex = pageIndex
            currentBottle = bottles?[Int(pageIndex)]
            
            if (nextVideoCard?.index ?? 0) == Int(currentIndex){
                currentVideoCard = nextVideoCard
            }else {
                currentVideoCard = videoCards[Int(currentIndex)]
            }
            
            
            // This line of code to remove the prevues card to avoid memory warning
            //videoCards[Int(currentIndex - 1)].removeFromSuperview()
            for i in scrollView.subviews {
                for j in  0...Int(currentIndex) - 1 {
                    if i == videoCards[j] {
                        i.removeFromSuperview()
                        videoCards[j]?.cancelBuffring()
                        videoCards[j]?.removeFromSuperview()
                        videoCards[j] = nil
                    }
                }
            }
            
            if currentVideoCard?.isVideoAvailable() ?? false {
                if currentVideoCard?.isVideoReady() ?? false {
                    currentVideoCard?.play(true)
                }
                currentVideoCard?.isAutoPlay = true
            }else {
                currentVideoCard?.configure(url: currentBottle?.attachment ?? "", isAutoPlay: true, customButton: self.playButton, delegate: self, index: Int(currentIndex), slideBar: self.slideBar)
            }
            
            setupVideoData()
            
            // Get the next 5 videos if needed
            if !isGettingVideos {
                if Int(currentIndex) == (self.bottles?.count ?? 0) - 2 {
                    self.fixedIndex = Int(self.currentIndex) + 2
                    getMoreVideos()
                    isGettingVideos = true
                }else if (Int(currentIndex) == (self.bottles?.count ?? 0) - 1) {
                    self.fixedIndex = Int(self.currentIndex) + 1
                    getMoreVideos()
                    isGettingVideos = true
                }
            }
            
            
            setupNextCard()
            
            // Flurry event
            let logEventParams = ["Shore": DataStore.shared.shores[self.currentShoreIndex].name_en ?? "Main Shore", "Gender": self.gender.rawValue, "Country": self.countryCode];
            Flurry.logEvent(AppConfig.swipe_bottle, withParameters:logEventParams);
            
        }else {
            // This code is to display to the user that there is no content when he reaches the last page
            if Int(self.currentIndex) == ((self.bottles?.count ?? 0) - 1) && self.displayNoContentMsg {
                self.showMessage(message: "NO_BOTTLES_FOUND".localized, type: .error)
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}

// MARK:- Functions
extension FindBottleViewController {
    func goToChat() {
        if let btl = currentBottle {
            FirebaseManager.shared.createNewConversation(bottle: btl, completionBlock: { (err, databaseReference) in
                if let _ = err {
                    self.showMessage(message: ServerError.unknownError.type.errorMessage, type: .error)
                } else {
                    self.showActivityLoader(false)
                    ApiManager.shared.replyToBottle(bottle: btl, completionBlock: { (success, err) in
                        if let error = err {
                            self.showMessage(message: error.type.errorMessage, type: .error )
                            return
                        }
                        
                        self.performSegue(withIdentifier: "goToChat", sender: databaseReference)
                    })
                    
                }
            })
        }
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: UIScreen.main.bounds.height)
        scrollView.contentSize = CGSize(width: view.frame.width , height: UIScreen.main.bounds.height * CGFloat(bottles?.count ?? 1))
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        
        for i in 0 ..< (bottles?.count ?? 0) {
            let card = VideoPlayerLayer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height * CGFloat(i), width: view.frame.width, height: UIScreen.main.bounds.height))
            
            videoCards.append(card)
            scrollView.addSubview(card)
        }
        
        // To adjust first card position
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        currentVideoCard = videoCards[Int(currentIndex)]
        currentVideoCard?.configure(url: currentBottle?.attachment ?? "", isAutoPlay: true, customButton: self.playButton, delegate: self, index: Int(currentIndex), slideBar: self.slideBar)
        
        setupNextCard()
    }
    
    func setupVideoData(){
        shoreNameLabel.text = currentBottle?.shore?.name
        userNameLabel.text = currentBottle?.owner?.userName
        countryFlag.image = countryPickerView.getCountryByName(currentBottle?.owner?.country?.nameEn ?? "")?.flag
        genderImage.image = currentBottle?.owner?.gender == .male ? UIImage(named: "signup_male") : UIImage(named: "signup_female")
        
        
        if let imgUrl = currentBottle?.owner?.profilePic, imgUrl.isValidLink() {
            userimage.sd_setShowActivityIndicatorView(true)
            userimage.sd_setIndicatorStyle(.gray)
            userimage.sd_setImage(with: URL(string: imgUrl))
        }else {
            userimage.image = UIImage(named:"user_placeholder")
        }

        
        currentVideoCard?.slideBar?.value = 0.0
    }
    
    func setupNextCard(){
        if (Int(currentIndex) + 1) <= ((bottles?.count ?? 0) - 1) {
            if let nextBottle = bottles?[Int(currentIndex) + 1]{
                nextVideoCard = videoCards[Int(currentIndex) + 1]
                nextVideoCard?.configure(url: nextBottle.attachment ?? "", isAutoPlay: false, customButton: self.playButton, delegate: self, index: Int(currentIndex) + 1, slideBar: self.slideBar)
                isNextCardCreated = true
            }
        }else {
            isNextCardCreated = false
        }
        
    }
    
    func getMoreVideos() {
        self.seen = DataStore.shared.seenVideos
        self.complete = DataStore.shared.completedVideos
        print(DataStore.shared.seenVideos)
        print(DataStore.shared.completedVideos)
        ApiManager.shared.findBottles(gender: gender.rawValue, countryCode: countryCode, shoreId: shoreId, seen: seen, complete: complete, offsets: Double(self.bottles?.count ?? 0), completionBlock: {(bottles, error) in
            
            self.isGettingVideos = false
            
            if error == nil  {
                if bottles != nil && bottles?.count != 0{
                    for i in bottles! {
                        self.bottles?.append(i)
                    }
                    
                    for i in self.fixedIndex ..< (self.bottles?.count ?? 0) {
                        let card = VideoPlayerLayer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height * CGFloat(i), width: self.view.frame.width, height: UIScreen.main.bounds.height))
                        
                        self.videoCards.append(card)
                        self.scrollView.addSubview(card)
                    }
                    
                    self.scrollView.contentSize = CGSize(width: self.view.frame.width , height: UIScreen.main.bounds.height * CGFloat(self.bottles?.count ?? 1))
                    
                    if !self.isNextCardCreated {
                        self.setupNextCard()
                    }
                    
                    self.displayNoContentMsg = false
                } else {
                    // no bottles found
                    self.displayNoContentMsg = true
                    
                }
                
                DataStore.shared.seenVideos = []
                DataStore.shared.completedVideos = []
            } else {
                // error ex. Authoriaztion error
                let alertController = UIAlertController(title: "", message: error?.type.errorMessage , preferredStyle: .alert)
                if error?.type == .authorization {
                    let actionCancel = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(actionCancel)
                    let actionLogout = UIAlertAction(title: "LOGIN_LOGIN_BTN".localized, style: .default,  handler: {(alert) in ActionLogout.execute()})
                    alertController.addAction(actionLogout)
                } else if error?.type == .accountDeactivated || error?.type == .deviceBlocked {
                    /// user should be forced to logout
                    let actionLogout = UIAlertAction(title: "ok".localized, style: .default,  handler: {(alert) in ActionLogout.execute()})
                    alertController.addAction(actionLogout)
                } else {
                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(ok)
                }
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
}


// MARK:- @IBAction
extension FindBottleViewController {
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
        if self.currentVideoCard?.isPlaying() ?? false {
            currentVideoCard?.playButtonPressed()
        }
        reportView.isHidden = false
        optionView.isHidden = true
    }
    
    @IBAction func blockBtnPressed(_ sender: Any) {
        if self.currentVideoCard?.isPlaying() ?? false {
            currentVideoCard?.playButtonPressed()
        }
        
        let blockMessage = String(format: "BLOCK_USER_WARNING".localized, "\(self.currentBottle?.owner?.userName ?? " ")")
        
        let alertController = UIAlertController(title: "", message: blockMessage , preferredStyle: .alert)
        //We add buttons to the alert controller by creating UIAlertActions:
        let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
            //self.dismiss(animated: true, completion: nil)
            // here send block to server
            if let bottleOwner = self.currentBottle?.owner {
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
        if let bottle = self.currentBottle {
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
        isGoingToSubViewController = true
        
        let repliesCount = (DataStore.shared.me?.repliesCount ?? 0) + (DataStore.shared.me?.extraRepliesCount ?? 0)
        //let repliesCount = 0
        if repliesCount != 0 {
            let logEventParams = ["Shore": shoreName ?? "", "AuthorGender": (currentBottle?.owner?.gender?.rawValue) ?? "", "AuthorCountry": (currentBottle?.owner?.countryISOCode) ?? ""];
            Flurry.logEvent(AppConfig.reply_pressed, withParameters:logEventParams);
            
            if self.currentVideoCard?.isPlaying() ?? false {
                currentVideoCard?.playButtonPressed()
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
                
                self.present(recordControl, animated: true, completion: nil)
            }
        }else {
            let getRepliesAction = UIAlertAction(title: "GET_REPLIES".localized, style: .default, handler: {_ in
                let moreRepliesVC = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: GetMoreViewController.className) as! GetMoreViewController
                
                moreRepliesVC.fType = .replies
                moreRepliesVC.providesPresentationContextTransitionStyle = true
                moreRepliesVC.definesPresentationContext = true
                moreRepliesVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                moreRepliesVC.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
                
                self.present(moreRepliesVC, animated: true, completion: nil)
            })
            self.showAlert(title: "GLOBAL_WARNING_TITLE".localized, message: "NO_REPLIES_MSG".localized , actions: [getRepliesAction])
        }
        
        
    }
    
    @IBAction func ignoreBtnPressed(_ sender: Any) {
        let logEventParams :[String : String] = ["Shore": shoreName ?? "", "AuthorGender": (currentBottle?.owner?.gender?.rawValue) ?? "", "AuthorCountry": (currentBottle?.owner?.countryISOCode) ?? ""];
        Flurry.logEvent(AppConfig.reply_ignored, withParameters:logEventParams);
        
        isGoingToSubViewController = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        currentVideoCard?.playButtonPressed()
    }
    
    @IBAction func didChangeTime(_ sender: UISlider) {
        currentVideoCard?.seekToTime(sender)
    }
    
    @IBAction func didFinishSliding(_ sender: UISlider) {
        currentVideoCard?.play()
    }
    
    @IBAction func unwindToFindBottle(segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.didSeenVideo()
            self.goToChat()
        }
    }
    
    @IBAction func showFilter (_ sender: Any) {
        if self.filterViewVisible {
            // hide
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.filterView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.filterView.frame.height - 50)
                self.filterViewOverlay.alpha = 0.0
            }, completion: {(finished: Bool) in
                self.filterViewVisible = false
                self.filterViewOverlay.isHidden = true
            })
        } else {
            // show
            if self.currentVideoCard?.isPlaying() ?? false {
                currentVideoCard?.playButtonPressed()
            }
            
            self.filterView.onFilterViewAppaer()
            self.filterView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.filterView.transform = CGAffineTransform.identity
                self.filterViewOverlay.alpha = 1.0
            }, completion: {(finished: Bool) in
                self.filterViewVisible = true
                self.filterViewOverlay.isHidden = false
            })
        }
        Flurry.logEvent(AppConfig.filter_click_from_find_bottle);
    }

}

extension FindBottleViewController: VideoPlayerDelegate {
    func didCompleteVideo() {
        let alreadyExist = DataStore.shared.completedVideos?.filter {$0 == self.currentBottle?.bottle_id!}
        
        if !(alreadyExist?.count ?? 0 > 0) {
            if let _ = DataStore.shared.completedVideos {
                DataStore.shared.completedVideos?.append((self.currentBottle?.bottle_id!)!)
            }else {
                DataStore.shared.completedVideos = [self.currentBottle?.bottle_id!] as? [String]
            }
        }
        
    }
    
    func didSeenVideo() {
        let alreadyExist = DataStore.shared.seenVideos?.filter {$0 == self.currentBottle?.bottle_id!}
        
        if !(alreadyExist?.count ?? 0 > 0) {
            if let _ = DataStore.shared.seenVideos {
                DataStore.shared.seenVideos?.append((self.currentBottle?.bottle_id!)!)
            }else {
                DataStore.shared.seenVideos = [self.currentBottle?.bottle_id!] as? [String]
            }
        }
    }
    
    func shakeVideoView() {
        //self.currentVideoCard?.shake(6, withDelta: 24, speed: 1, shakeDirection: .vertical)
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

extension FindBottleViewController: FilterViewDelegate {
    func filterViewGet(_ filterView: FilterView, gender: String, country: String) {
        
        self.gender = GenderType(rawValue: gender)!
        self.countryCode = country

        
    }
    
    func filterViewShowBuyFilterMessage(_ filterView: FilterView, type: ShopItemType) {
        
    }
    
    func filterViewFindBottle(_ filterView: FilterView) {
        // hide filters view is
        self.showFilter(self)
        
        self.seen = DataStore.shared.seenVideos
        self.complete = DataStore.shared.completedVideos
        self.showActivityLoader(true)
    
        ApiManager.shared.findBottles(gender: self.gender.rawValue, countryCode: self.countryCode, shoreId: self.shoreId, seen: seen, complete: complete, offsets: 0, completionBlock: {(bottles, error) in
            
            self.isGettingVideos = false
            self.showActivityLoader(false)
            
            if error == nil  {
                if bottles != nil && bottles?.count != 0{
                    self.currentVideoCard?.cancelBuffring()
                    self.nextVideoCard?.cancelBuffring()
                    
                    self.bottles = nil
                    self.videoCards = []
                    self.currentIndex = 0.0
                    self.fixedIndex = 0
                    self.lastVelocityYSign = 0
                    self.displayNoContentMsg = false
                    
                    self.bottles = bottles
                    
                    if self.bottles?.count ?? 0 > 0 {
                        self.currentBottle = self.bottles?[0]
                    }
                    
                    self.setupVideoData()
                    self.setupScrollView()
                    
                    
                } else {
                    // no bottles found
                    self.showMessage(message: "NO_BOTTLES_FOUND".localized, type: .error)
                }
                
                DataStore.shared.seenVideos = []
                DataStore.shared.completedVideos = []
            } else {
                // error ex. Authoriaztion error
                let alertController = UIAlertController(title: "", message: error?.type.errorMessage , preferredStyle: .alert)
                if error?.type == .authorization {
                    let actionCancel = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(actionCancel)
                    let actionLogout = UIAlertAction(title: "LOGIN_LOGIN_BTN".localized, style: .default,  handler: {(alert) in ActionLogout.execute()})
                    alertController.addAction(actionLogout)
                } else if error?.type == .accountDeactivated || error?.type == .deviceBlocked {
                    /// user should be forced to logout
                    let actionLogout = UIAlertAction(title: "ok".localized, style: .default,  handler: {(alert) in ActionLogout.execute()})
                    alertController.addAction(actionLogout)
                } else {
                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(ok)
                }
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func filterViewGoToShop(_ filterView: FilterView, productType: ShopItemType) {
       
    }
    
    func filterBuyItem(_ filterView: FilterView, product: ShopItem) {
        var prodcutType = "country"
        if product.type == .genderFilter {
            prodcutType = "gender"
        }
        
        
        if (DataStore.shared.me?.pocketCoins ?? 0) >= (product.priceCoins ?? 0) {
            
            let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(product.priceCoins ?? 0) " + "COINS".localized) , preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                
                
                // flurry events
                
                let logEventParams = ["prodType": prodcutType, "ProdName": product.title_en ?? ""];
                Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                
                self.showActivityLoader(true)
                
                ApiManager.shared.purchaseItemByCoins(shopItem: product, completionBlock: {isSuccess, error, shopItem in
                    if error == nil {
                        DataStore.shared.me?.pocketCoins! -= (product.priceCoins ?? 0)
                        
                        ApiManager.shared.getMe(completionBlock: { (success, err, user) in
                            self.showActivityLoader(false)
                            
                            let inventoryItem = InventoryItem()
                            inventoryItem.isValid = true
                            inventoryItem.isConsumed = false
                            inventoryItem.shopItem = product
                            inventoryItem.startDate = Date().timeIntervalSince1970
                            inventoryItem.endDate = Date().timeIntervalSince1970 + ((product.validity ?? 1) * 60 * 60)
                            DataStore.shared.inventoryItems.append(inventoryItem)
                            
                            // flurry events, on purchase done
                            let logEventParams2 = ["prodType": prodcutType, "ProdName": product.title_en ?? ""];
                            Flurry.logEvent(AppConfig.shop_purchase_complete, withParameters:logEventParams2);
                            
                            self.filterView.refreshFilterView()
                            
                        })
                        
                        
                    }else {
                        self.showActivityLoader(false)
                        self.showMessage(message: error?.type.errorMessage ?? "", type: .error)
                    }
                    
                })
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }else {
            
            let alertController = UIAlertController(title: "", message: "NO_ENOUGH_COINS_MSG".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "GET_COINS".localized, style: .default, handler: { (alertAction) in
                
                let shopVC = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: ShopViewController.className) as! ShopViewController
                shopVC.fType = .coinsPack
                
                self.isGoingToSubViewController = true
                self.present(shopVC, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        // flurry events
        let logEventParams = ["prodType": prodcutType];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
    }
    
    func didPressOnCountryFilter() {
        self.isGoingToSubViewController = true
    }
}
