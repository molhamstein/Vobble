//
//  HomeViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import SwiftyGif

class HomeViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet var ivSea: UIImageView!
    @IBOutlet var ivWaves: UIImageView!
    @IBOutlet var ivSky: UIImageView!
    @IBOutlet var ivClouds: UIImageView!
    @IBOutlet var ivMountains: UIImageView!
    @IBOutlet var ivSun: UIImageView!
    @IBOutlet var ivIsland: UIImageView!
    @IBOutlet var ivShore1Shore: UIImageView!
    @IBOutlet var ivShore2Shore: UIImageView!
    @IBOutlet var ivShore2Umbrella: UIImageView!
    @IBOutlet var shore2Lovers: UIView!
    @IBOutlet var ivShore3Shore: UIImageView!
    @IBOutlet var shore3Friends: UIView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    @IBOutlet weak var filterViewOverlay: UIView!
    @IBOutlet weak var filterView: FilterView!
    
    // throw
    @IBOutlet weak var vThrowBtnContainer: UIView!
    @IBOutlet weak var lblThrowBtn: UILabel!
    @IBOutlet weak var btnThrowBtn: UIButton!
    @IBOutlet weak var ivThrowBtn: UIImageView!
    @IBOutlet weak var lblBottlesLeftBadge: UILabel!
    @IBOutlet weak var vThrowBtnCircle: UIView!
    
    // my bottles
    @IBOutlet weak var vMyBottlesBtnContainer: UIView!
    @IBOutlet weak var lblMyBottlesBtn: UILabel!
    @IBOutlet weak var btnMyBottlesBtn: UIButton!
    @IBOutlet weak var ivMyBottlesBtn: UIImageView!
    @IBOutlet weak var vMyBottlesBtnCircle: UIView!
    @IBOutlet weak var lblUnreadConversationsBadge: UILabel!
    // find
    @IBOutlet weak var vFindBtnContainer: UIView!
    @IBOutlet weak var lblFindBtn: UILabel!
    @IBOutlet weak var btnFindBtn: UIButton!
    @IBOutlet weak var ivFindBtn: UIImageView!
    @IBOutlet weak var vFindBtnCircle: UIView!
    
    // GIF images
    @IBOutlet var ivShore2Girl: UIImageView!
    @IBOutlet var ivShore3Girl1: UIImageView!
    @IBOutlet var ivShore3Girl2: UIImageView!
    @IBOutlet var ivShore3Boy: UIImageView!
    @IBOutlet var ivFire: UIImageView!
    @IBOutlet var ivCrap: UIImageView!
    @IBOutlet var ivShark: UIImageView!
    @IBOutlet var ivBoat: UIImageView!
    
    @IBOutlet var sonTopConstraint: NSLayoutConstraint!
    
    var screenWidth: CGFloat = 0.0;
    var blockPageTransitions: Bool = false;
    var currentPageIndex :Int = 0;
    var isInitialized = false
    
    let seaParallaxSpeed :CGFloat = 0.3
    let sunParallaxSpeed :CGFloat = 0.015
    let cloudsParallaxSpeed :CGFloat = 0.2
    let mountainsParallaxSpeed :CGFloat = 0.15
    let island2ParallaxSpeed :CGFloat = 0.2
    let shore1ParallaxSpeed :CGFloat = 1.0
    let shore2ParallaxSpeed :CGFloat = 1.0
    let shore3ParallaxSpeed :CGFloat = 1.0
    let loversParallaxSpeed :CGFloat = 1.0
    let friendsParallaxSpeed :CGFloat = 1.0
    
    // bottle animations 
    @IBOutlet var ivFindBottle: UIImageView!
    @IBOutlet var ivThrowBottle: UIImageView!
   
    var panRecognizer: UIPanGestureRecognizer?
    
    //filter option
    var countryCode = ""
    var gender = GenderType.allGender
    
    var introAnimationDone: Bool = false
    var filterViewVisible = false
    
    // temp Data Holders
    var productType: ShopItemType?
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable profile
        self.showNavProfileButton = true
        self.navigationView.viewcontroller = self
        self.navigationView.mode = .home
        self.filterView.delegate = self
        
        // hide filters View by default
        self.filterView.isHidden = true
        self.filterView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.filterView.frame.height - 50)
        self.filterViewOverlay.alpha = 0.0
        
        // prefetch the conversations to make sure they apear faster
        FirebaseManager.shared.fetchMyBottlesConversations { (err) in}
        FirebaseManager.shared.fetchMyRepliesConversations { (err) in}
        
        // move the sun up to make sure no edges show when the navigations bar is flipped in arabic
        if AppConfig.currentLanguage == .arabic {
            sonTopConstraint.constant = -38
        } else {
            sonTopConstraint.constant = -16
        }
        
        // observe any change in the unread notifications count
        lblUnreadConversationsBadge.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesCountChange(notification:)), name: Notification.Name("unreadMessagesChange"), object: nil)
        
        // tutorial
        if let tutShowedBefore = DataStore.shared.tutorial1Showed, !tutShowedBefore{
            dispatch_main_after(2) {
                let viewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "Annotation") as! AnnotationViewController
                viewController.alpha = 0.5
                viewController.homeViewController = self
                self.present(viewController, animated: true, completion: nil)
                
                DataStore.shared.tutorial1Showed = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenWidth = self.view.frame.size.width;
     
        // animate sea waves
//        ivWaves?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0)).translatedBy(x: -2, y: 6)
//        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.ivWaves?.transform = CGAffineTransform.identity.translatedBy(x: 2, y: -2)
//        }, completion: nil)
        
        ivShore2Umbrella.setAnchorPoint(anchorPoint: CGPoint(x: 0.483 , y: 0.71))
        ivShore2Umbrella?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0))
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.ivShore2Umbrella?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0.05))
        }, completion: nil)
        
        //ivSea.setAnchorPoint(anchorPoint: CGPoint(x: 0.483 , y: 0.71))
//        ivWaves?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0)).translatedBy(x: 0, y: 0)
//        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.ivWaves?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0.0)).translatedBy(x: 0, y: 10)
//        }, completion: nil)
        
        if currentPageIndex == 0 {
            animateCrab()
        }
        self.animateShark()
        
        ApiManager.shared.getMe(completionBlock: { (success, error, user) in})
        ApiManager.shared.requestUserInventoryItems { (items, error) in}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // animate view in
        if !introAnimationDone {
            ivClouds.animateIn(mode: .animateInFromTop, delay: 0.2)
            ivMountains.animateIn(mode: .animateInFromTop, delay: 0.3)
            ivSun.animateIn(mode: .animateInFromLeft, delay: 0.4)
            ivIsland.animateIn(mode: .animateInFromRight, delay: 0.5)
            ivShore1Shore.animateIn(mode: .animateInFromLeft, delay: 0.5)
            navigationView.animateIn(mode: .animateInFromTop, delay: 0.8)
            ivCrap.animateIn(mode: .animateInFromBottom, delay: 0.6)
            
//            self.popAnimation(view: self.vMyBottlesBtnCircle)
//            self.popAnimation(view: self.vFindBtnCircle)
//            self.popAnimation(view: self.vThrowBtnCircle)
            introAnimationDone = true
        }
        
        self.setArtImages()
        filterView?.refreshFilterView()
        refreshViewData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//            self.ivWaves?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0)).translatedBy(x: 0, y: 0)
//            UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
//                self.ivWaves?.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 20)
//            }, completion: nil)
//        }
    }
    
    /// Customize view
    override func customizeView() {
        
        // Wording
        lblThrowBtn.text = "HOME_THROW_BTN".localized
        lblFindBtn.text = "HOME_FIND_BTN".localized
        lblMyBottlesBtn.text = "HOME_MY_BOTTLES_BTN".localized
        self.navigationView.navTitle.text = "main_shore".localized
        
        // fonts
        lblThrowBtn.font = AppFonts.xSmallBold
        lblFindBtn.font = AppFonts.xSmallBold
        lblMyBottlesBtn.font = AppFonts.xSmallBold
        
        //add geture recognizer for swipping horizontally
        panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panRecognizer?.delegate = self
        self.view.addGestureRecognizer(panRecognizer!)
        
        // tab on sea to find bottle
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(seaTapped(tapGestureRecognizer:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.ivShore2Girl.setGifImage(UIImage(gifName: "girl.gif"))
        self.ivShore3Girl1.setGifImage(UIImage(gifName: "girl_3_1.gif"))
        self.ivShore3Girl2.setGifImage(UIImage(gifName: "girl_3_2.gif"))
        //self.ivThrowBottle.loopCount = 1
        
//        self.ivShore2Girl.loadGif(name: "girl")
//        self.ivShore3Girl1.loadGif(name: "girl_3_1")
//        self.ivShore3Girl2.loadGif(name: "girl_3_2")
        
        filterView.delegate = self
    }
    
    func refreshViewData () {
        
        lblBottlesLeftBadge.text = "\(DataStore.shared.me?.bottlesLeftToThrowCount ?? 0)"
    }
    
    func setArtImages(){
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let isNight = hour >= 18 || hour <= 5
        //let isNight = false
        
        //hours += 1
        if isNight {
            ivSea.image = UIImage(named:"sea_night")
            ivSky.image = UIImage(named:"sky1_night")
            ivClouds.image = nil
            ivMountains.image = UIImage(named:"montains_night")
            ivSun.image = UIImage(named:"sun_night")
            ivIsland.image = UIImage(named:"island_night")
            ivShore1Shore.image = UIImage(named:"shore1_night")
            ivShore2Shore.image = UIImage(named:"shore2_night")
            ivShore3Shore.image = UIImage(named:"shore3_night")
            ivFire.setGifImage(UIImage(gifName: "fire.gif"))
            
            //ivWaves.image = nil
        } else {
            ivSea.image = UIImage(named:"sea")
            ivSky.image = UIImage(named:"sky1")
            ivClouds.image = UIImage(named:"clouds")
            ivMountains.image = UIImage(named:"montains")
            ivSun.image = UIImage(named:"sun")
            ivIsland.image = UIImage(named:"island")
            ivShore1Shore.image = UIImage(named:"shore1")
            ivShore2Shore.image = UIImage(named:"shore2")
            ivShore3Shore.image = UIImage(named:"shore3")
            ivFire.image = nil
            
            //ivWaves.image = nil
        }
        
        ivCrap.setGifImage(UIImage(gifName: "crab.gif"))
        ivCrap.loopCount = -1
//        ivCrap?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0)).translatedBy(x: 0, y: 0)
//        UIView.animate(withDuration: 35.0, delay: 0, options: [.repeat, .autoreverse, .curveLinear], animations: {
//            self.ivCrap?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth * 2, y: 0)
//        }, completion: nil)
        
    }
    
    func disableActions (disable: Bool) {
        if disable {
            self.view.isUserInteractionEnabled = false
            btnMyBottlesBtn.isUserInteractionEnabled = false
            btnFindBtn.isUserInteractionEnabled = false
            btnThrowBtn.isUserInteractionEnabled = false
        } else {
            self.view.isUserInteractionEnabled = true
            btnMyBottlesBtn.isUserInteractionEnabled = true
            btnFindBtn.isUserInteractionEnabled = true
            btnThrowBtn.isUserInteractionEnabled = true
        }
    }
    
    func animateCrab() {
        self.ivCrap?.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        UIView.animate(withDuration: 35.0, delay: 0, options: [.repeat, .autoreverse, .curveLinear], animations: {
            self.ivCrap?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth * 2, y: 0)
        }, completion: nil)
    }
    
    func animateShark() {
//        ivShark?.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
        
//        UIView.animate(withDuration: 18.0, delay: 5, options: [.repeat, .curveLinear], animations: {
//            self.ivShark?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth * 3, y: 0)
//        }, completion: nil)
        
//        UIView.animateKeyframes(withDuration: 18, delay: 3, options: [.repeat], animations: {
//            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
//                self.ivShark?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth/3 , y: 8).rotated(by: 0.1).scaledBy(x: 1.08, y: 1.08)
//            }
//            UIView.addKeyframe(withRelativeStartTime: 0.33, relativeDuration: 0.33) {
//                self.ivShark?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth/2, y: 0)
//            }
//            UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.34) {
//                self.ivShark?.transform = CGAffineTransform.identity.translatedBy(x: self.screenWidth , y: -8)
//            }
//        }) { (done) in
//            
//        }
        
//        ivShark?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0)).translatedBy(x: 0, y: 0)
//        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.ivShark?.transform = CGAffineTransform.identity.rotated(by: CGFloat(0.0)).translatedBy(x: 0, y: 10)
//        }, completion: nil)
        
        
        let maxYTransaltion = CGFloat(80.0)
        
        let randX = CGFloat( arc4random_uniform(UInt32(300)) )
        let randY = CGFloat( arc4random_uniform(UInt32(maxYTransaltion)) )
        let randDelay: Double = Double(arc4random_uniform(UInt32(12) + 4))
        DispatchQueue.main.asyncAfter(deadline: .now() + randDelay) {
            self.ivShark?.transform = CGAffineTransform.identity.translatedBy(x: randX, y: randY).scaledBy(x: randY/(maxYTransaltion * 2) + 1.0, y: (randY/(maxYTransaltion * 2)) + 1.0)
            let dolphinGif = UIImage(gifName: "dolphin.gif")
            self.ivShark.setGifImage(dolphinGif)
            self.ivShark.loopCount = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                // stop the gif from replay 
                self.ivShark.image = nil
            }
        }
    }
    
    func unreadMessagesCountChange (notification: NSNotification) {
        let count = DataStore.shared.getConversationsWithUnseenMessagesCount()
        if count > 0{
            lblUnreadConversationsBadge.text = "\(DataStore.shared.getConversationsWithUnseenMessagesCount())"
            lblUnreadConversationsBadge.isHidden = false
        } else {
            lblUnreadConversationsBadge.isHidden = true
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let bottle = sender as? Bottle {
            let nav = segue.destination as! UINavigationController
            let findBottleVC = nav.topViewController as! FindBottleViewController
            //findBottleVC.shoreName = self.navigationView.navTitle.text
            findBottleVC.bottle = bottle
        
        } else if segue.identifier == "shopSegue" {
            let vc = segue.destination as! ShopViewController
            if let type = productType {
                vc.fType = type
            }
        }
    }
    
    @IBAction func throwBottlePressed(_ sender: UIButton) {
       
        //ActionRateUs.execute(hostViewController: self)
        
        if let bCount = DataStore.shared.me?.bottlesLeftToThrowCount, bCount > 0 {
            //DataStore.shared.me?.thrownBottlesCount = bCount - 1
            //self.wiggleAnimate(view: self.ivThrowBtn)
            self.popAnimation(view: self.vThrowBtnCircle)
            
            self.disableActions(disable: true)
            // add a delay to show button press animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.disableActions(disable: false)
                self.performSegue(withIdentifier: "homeRecrodSegue", sender: self)
            }
            
            Flurry.logEvent(AppConfig.throw_bottle);
            
        } else {
            
            self.wiggleAnimate(view: self.ivThrowBtn)
            
            let alertController = UIAlertController(title: "", message: "THROW_BOTTLE_WARNING".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
            let getBottlesAction = UIAlertAction(title: "THROW_BOTTLE_WARNING_ACTION".localized, style: .default,  handler: {(alert) in 
                self.showShopView(.bottlesPack)
                })
            alertController.addAction(ok)
            alertController.addAction(getBottlesAction)
            self.present(alertController, animated: true, completion: nil)
       }
    }

    func seaTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        // make sure the tap is in the middle section of the view "where the sea is"
        let translation: CGPoint = tapGestureRecognizer.location(in: self.view)
        let tapLocationRatio = translation.y / self.view.frame.height
        if tapLocationRatio > 0.25 && tapLocationRatio < 0.6 && !self.filterViewVisible {
            self.findBottlePressed(ivSea)
        }
    }
    
    @IBAction func findBottlePressed(_ sender: Any) {
       
        let findBottleGif = UIImage(gifName: "find_bottle.gif")
        self.ivFindBottle.setGifImage(findBottleGif)
        self.ivFindBottle.loopCount = 1
        //self.wiggleAnimate(view: self.ivFindBtn)
        self.popAnimation(view: self.vFindBtnCircle)
        
        // send tracking event
        let logEventParams = ["Shore": DataStore.shared.shores[self.currentPageIndex].name_en ?? "Main Shore", "Gender": self.gender.rawValue, "Country": self.countryCode];
        Flurry.logEvent(AppConfig.find_bottle, withParameters:logEventParams);
        
        // filters tracking events
        
        // make sure user wont move to other shores while playing animation 
        self.disableActions(disable: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // delay 5 second
            self.ivFindBottle.image = nil
            self.showActivityLoader(true)
            
            let shoreId = self.currentPageIndex == 0 ? nil : DataStore.shared.shores[self.currentPageIndex].shore_id!
            ApiManager.shared.findBottle(gender: self.gender.rawValue, countryCode: self.countryCode, shoreId: shoreId, completionBlock: { (bottle, error) in
                self.disableActions(disable: false)
                self.showActivityLoader(false)
                if error == nil  {
                    if bottle != nil {
                        //print("\(bottle?.bottle_id)")
                        self.performSegue(withIdentifier: "findBottleSegue", sender: bottle)
                    } else {
                        // no bottles found
                        let logEventParams = ["Shore": (DataStore.shared.shores[self.currentPageIndex].name_en) ?? "", "Gender": self.gender.rawValue, "Country": self.countryCode];
                        Flurry.logEvent(AppConfig.find_bottle_not_found, withParameters:logEventParams);
                        
                        let alertController = UIAlertController(title: "", message: error?.type.errorMessage , preferredStyle: .alert)
                        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    // error ex. Authoriaztion error
                    let alertController = UIAlertController(title: "", message: error?.type.errorMessage , preferredStyle: .alert)
                    if error?.type == .authorization {
                        let actionCancel = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                        alertController.addAction(actionCancel)
                        let actionLogout = UIAlertAction(title: "LOGIN_LOGIN_BTN".localized, style: .default,  handler: {(alert) in ActionLogout.execute()})
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
    
    @IBAction func myBottlesPressed(_ sender: UIButton) {
        //self.wiggleAnimate(view: self.ivMyBottlesBtn)
        self.popAnimation(view: self.vMyBottlesBtnCircle)
        self.disableActions(disable: true)
        // add a delay to show button press animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.disableActions(disable: false)
            self.performSegue(withIdentifier: "myBottlesSegue", sender: self)
        }
    }
    
    @IBAction func unwindSendReply(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindRecordMedia(segue: UIStoryboardSegue) {
        
        let throwBottleGif = UIImage(gifName: "throwBottle.gif")
        self.ivThrowBottle.setGifImage(throwBottleGif)
        self.ivThrowBottle.loopCount = 1
        
        if let sourceController = segue.source as? PreviewMediaControl {
            switch sourceController.selectedShoreIndex {
            case 0:
                goToMainShore()
            case 1:
                goToLoveShore()
            case 2:
                goToFadFedShore()
            default:
                goToMainShore()
            }
        
            // optimistic update for user throwed bottles count
            if let bottlesLeftCount = DataStore.shared.me?.bottlesLeftToThrowCount {
                DataStore.shared.me?.bottlesLeftToThrowCount = bottlesLeftCount - 1
                self.refreshViewData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { // delay 6 second
                self.ivThrowBottle.image = nil
                // update user infoafter throwing the bottle
                ApiManager.shared.getMe(completionBlock: { (success, error, user) in
                    // check the number of bottles thrown by user, and use it to determine 
                    // if we should show the rate us dialog 
                    ActionRateUs.execute(hostViewController: self)
                    self.refreshViewData()
                })
            }
        }
    }
    
    func wiggleAnimate(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 15, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 15, y: view.center.y))
        
        view.layer.add(animation, forKey: "position")
    }
    
    func popAnimation(view: UIView) {
        
        view.transform = CGAffineTransform.identity.scaledBy(x: 1.15, y: 1.15)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                UIView.setAnimationRepeatCount(2)
                view.transform = CGAffineTransform.identity
        }) { (done) in
//            UIView.animate(withDuration: 2.0, delay: 0.0, options: [], animations: {
//                view.transform = CGAffineTransform.identity
//            }) { (done) in
//            }
        }
    }

    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
        } else if gestureRecognizer.state == .changed {
            
            print("gest changing")
            if blockPageTransitions {
                print("gest blocked")
                return
            }
            
            let translation: CGPoint = gestureRecognizer.translation(in: view)
            //print("gest pan right \(fabs(translation.x/translation.y))")
            // min threshold for swipe
            if fabs(translation.x) < 30  || fabs(translation.y/translation.x) > 0.9{
                return
            }
            if translation.x < 0 {
                // swipping foreward to next screen
                if currentPageIndex == 0 {
                    //let transform = CGAffineTransform.identity.translatedBy(x: translation.x, y: 0)
                    let duration = 0.1
                    UIView.animate(withDuration: duration, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.loversParallaxSpeed, y: 0)
                        self.ivCrap.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore1ParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: translation.x * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                } else if currentPageIndex == 1 {
                    //let transform = CGAffineTransform.identity.translatedBy(x: translation.x, y: 0)
                    let duration = 0.1
                    let trans = (self.screenWidth * -1) + translation.x
                    UIView.animate(withDuration: duration, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        // shore 2
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        // shore 3
                        self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore3ParallaxSpeed, y: 0)
                        self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        //self.ivFire.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: translation.x * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                }
            } else {
                // swipping back to previews view
                if currentPageIndex == 0 {
                    // no action to take
                } else if currentPageIndex == 1 {
                    let trans = (translation.x - self.screenWidth)
                    UIView.animate(withDuration: 0.1, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        self.ivCrap.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore1ParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                } else if currentPageIndex == 2 {
                    let trans = (translation.x - (self.screenWidth * 2))
                    UIView.animate(withDuration: 0.1, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        // shore 3
                        self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore3ParallaxSpeed, y: 0)
                        self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        //self.ivFire.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                }
            }
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            if blockPageTransitions {
                return
            }
            let translation: CGPoint = gestureRecognizer.translation(in: view)
            if (translation.x >= 100) {
                // moving back view
                if (currentPageIndex == 0) {
                    // no action to take
                    blockPageTransitions = false;
                } else if ( currentPageIndex == 1 ) {
                    self.goToMainShore()
                } else if ( currentPageIndex == 2 ) {
                    self.goToLoveShore()
                }
            } else if (translation.x <= -100) {
                // moving to next view
                if (currentPageIndex == 0) {
                    self.goToLoveShore()
                } else if currentPageIndex == 1 {
                    self.goToFadFedShore()
                } else {
                    blockPageTransitions = false;
                    // no action to take
                }
            } else {
                // swipe distance was small
                // reset views to original locations
                if (currentPageIndex == 0) {
                    self.goToMainShore()
                } else if ( currentPageIndex == 1 ) {
                    self.goToLoveShore()
                } else {
                    self.goToFadFedShore()
                }
            }
        }
    }
    
    
    func goToMainShore() {
        
        if blockPageTransitions {
            return
        }
        blockPageTransitions = true
        self.navigationView.navTitle.text = "main_shore".localized
        //let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity
            self.ivIsland.transform = CGAffineTransform.identity
            self.ivShore1Shore.transform = CGAffineTransform.identity
            self.ivShore2Shore.transform = CGAffineTransform.identity
            self.ivShore3Shore.transform = CGAffineTransform.identity
            self.shore3Friends.transform = CGAffineTransform.identity
            //self.ivFire.transform = CGAffineTransform.identity
            self.shore2Lovers.transform = CGAffineTransform.identity
            self.ivMountains.transform = CGAffineTransform.identity
            self.ivSun.transform = CGAffineTransform.identity
            self.ivClouds.transform = CGAffineTransform.identity
            self.ivCrap.transform = CGAffineTransform.identity
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 0
            self.blockPageTransitions = false
            
            // animate the crab 
            self.animateCrab()

        })
    }
    
    func goToLoveShore() {
        if blockPageTransitions {
            return
        }
        
        ivCrap.stopAnimating()
        
        blockPageTransitions = true
        self.navigationView.navTitle.text = "love_shore".localized
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.seaParallaxSpeed), y: 0)
            self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.island2ParallaxSpeed), y: 0)
            self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore1ParallaxSpeed), y: 0)
            self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore2ParallaxSpeed), y: 0)
            self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore3ParallaxSpeed), y: 0)
            self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.friendsParallaxSpeed), y: 0)
            //self.ivFire.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.friendsParallaxSpeed), y: 0)
            self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.loversParallaxSpeed), y: 0)
            self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.sunParallaxSpeed), y: 0)
            self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.cloudsParallaxSpeed), y: 0)
            self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.mountainsParallaxSpeed), y: 0)
            self.ivCrap.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore1ParallaxSpeed), y: 0)
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 1
            self.blockPageTransitions = false
        })
    }
    
    func goToFadFedShore() {
        if blockPageTransitions {
            return
        }
        
        ivCrap.stopAnimating()
        
        blockPageTransitions = true
        self.navigationView.navTitle.text = "fadfed_shore".localized
        //let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        let doubleScreenWidth = self.screenWidth * 2
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.seaParallaxSpeed), y: 0)
            self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.island2ParallaxSpeed), y: 0)
            self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore1ParallaxSpeed), y: 0)
            self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore2ParallaxSpeed), y: 0)
            self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore3ParallaxSpeed), y: 0)
            self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.friendsParallaxSpeed), y: 0)
            //self.ivFire.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.friendsParallaxSpeed), y: 0)
            self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.loversParallaxSpeed), y: 0)
            self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.sunParallaxSpeed), y: 0)
            self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.cloudsParallaxSpeed), y: 0)
            self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.mountainsParallaxSpeed), y: 0)
            self.ivCrap.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore1ParallaxSpeed), y: 0)
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 2
            self.blockPageTransitions = false
        })
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
            // enable shores navigation back
            panRecognizer?.isEnabled = true
        } else {
            // show
            self.filterView.onFilterViewAppaer()
            self.filterView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.filterView.transform = CGAffineTransform.identity
                self.filterViewOverlay.alpha = 1.0
            }, completion: {(finished: Bool) in
                self.filterViewVisible = true
                self.filterViewOverlay.isHidden = false
            })
            // disable shores navigation as the gesture is interferring with the countries picker
            panRecognizer?.isEnabled = false
        }
        Flurry.logEvent(AppConfig.filter_click);
    }
    
    func showShopView(_ productType: ShopItemType?) {
        self.productType = productType
        self.performSegue(withIdentifier:"shopSegue", sender: self)
    }
    
}

extension HomeViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: FilterViewDelegate {
    
    func filterViewGet(_ filterView: FilterView, gender: String, country: String) {
        
        self.gender = GenderType(rawValue: gender)!
        self.countryCode = country
    }
    
    func filterViewShowBuyFilterMessage(_ filterView: FilterView, type: ShopItemType) {
        
        let alertController = UIAlertController(title: "", message: "BUY_FILTER_WARNING".localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: "GO_TO_SHOP".localized, style: .default, handler: { (alertAction) in
            // flurriny event
            let logEventParams = ["From": "filter"];
            Flurry.logEvent(AppConfig.shop_enter, withParameters:logEventParams);
            
            self.showShopView(type)
        })
        alertController.addAction(ok)
        let cancel = UIAlertAction(title: "cancel".localized, style: .default,  handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func filterViewFindBottle(_ filterView: FilterView) {
        // hide filters view is
        self.showFilter(self)
        self.findBottlePressed(self.ivFindBtn)
    }
    
    func filterViewGoToShop(_ filterView: FilterView, productType: ShopItemType) {
        let logEventParams = ["From": "filter"];
        Flurry.logEvent(AppConfig.shop_enter, withParameters:logEventParams);
        self.showShopView(productType)
    }
}

// tutorial
extension HomeViewController {

    func tutorialActon1() {
        self.goToLoveShore()
    }
    
    func tutorialActon2() {
        self.goToMainShore()
        dispatch_main_after(2) {
            let viewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "Annotation") as! AnnotationViewController
            viewController.alpha = 0.7
            viewController.stepIndex = 3
            viewController.homeViewController = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func tutorialActon3FindBottle() {
        self.goToMainShore()
        dispatch_main_after(0.5) {
            self.findBottlePressed(self.ivFindBtn)
        }
    }
    
}


