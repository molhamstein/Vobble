//
//  PreviewMediaControl.swift
//  Vobble
//
//  Created by Dania on 6/3/17.
//
//

import AVFoundation
import UIKit
import Flurry_iOS_SDK
import Firebase

enum MEDIA_TYPE {
    case IMAGE
    case VIDEO
}

class PreviewMediaControl : AbstractController {
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var vOverlay:UIView!
    @IBOutlet weak var cvShorePicker:UICollectionView!
    @IBOutlet weak var submitButton: VobbleButton!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet var vp: VideoPlayerView!
    @IBOutlet weak var playButton: UIButton!
    
    // upload progress
    @IBOutlet weak var uploadProgressWater: UIView!
    @IBOutlet weak var uploadProgressLabel: UILabel!
    @IBOutlet weak var uploadProgressWave: WaveView!
    
    var type:MEDIA_TYPE!
    var isShorePickerVisible: Bool = false
    var from: typeOfController = .chatView
    var isVOverlayApplyGradient:Bool = false
    var selectedShoreIndex: Int = -1
    var selectedShore: Shore?
    
    //Image
    var image = UIImage();
    var imgUrl:String = ""
    
    //Video
    var videoUrl = NSURL();
    
    //Topic
    var topicId: String?
    
    var soundPlayer : AVAudioPlayer!
    var parentVC: UIViewController!
    
//    var avPlayer = AVPlayer();
//    var avPlayerLayer = AVPlayerLayer();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false);
//        if(type == .VIDEO) {
//            self.avPlayer.play();
//        }
        
        if (from == .findBottle) {
            
            cvShorePicker.isHidden = true
            submitButton.isHidden = false
            retakeButton.isHidden = false
            
        } else if (from == .throwBottle) {
            
            cvShorePicker.isHidden = true
            submitButton.isHidden = false
            retakeButton.isHidden = false
            
        } else if (from == .chatView) {
            
            cvShorePicker.isHidden = true
            submitButton.isHidden = true
            retakeButton.isHidden = true
        }
        
        // itro animation 
        cvShorePicker.animateIn(mode: .animateInFromBottom, delay: 0.3)
        backButton.animateIn(mode: .animateInFromTop, delay: 0.2)
        
//        self.vOverlay.applyGradient(colours: [ AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
        
//        vp.preparePlayer(videoURL: self.videoUrl as URL)
        vp.preparePlayer(videoURL: self.videoUrl.absoluteString!, customPlayBtn: playButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.avPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        if !isVOverlayApplyGradient {
            self.vOverlay.applyGradient(colours: [ AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
            self.submitButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
            
            uploadProgressWave.awakeFromNib()
            uploadProgressWave.showWave()
            uploadProgressWave.isHidden = true
            uploadProgressWater.isHidden = true
            
            isVOverlayApplyGradient = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    func initViews() {
        
        self.submitButton.setTitle("SUBMIT".localized, for: .normal)
        
        self.backButton.tintColor = UIColor.white
        self.vOverlay.bringToFront()
        self.cvShorePicker.bringToFront()
        self.submitButton.bringToFront()
        self.retakeButton.bringToFront()
        
        // regisert the shores picker cells
        let shoreNib = UINib(nibName: "ShoreCell", bundle: nil)
        cvShorePicker.register(shoreNib, forCellWithReuseIdentifier: "ShoreCell")
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
//        self.avPlayer.seek(to: kCMTimeZero)
    }
    
    @IBAction func dissmiss() {
        //Image
        image = UIImage()
        imgUrl = ""
        //Video
        videoUrl = NSURL()
        self.parentVC.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func retake() {
        //Image
        image = UIImage()
        imgUrl = ""
        //Video
        videoUrl = NSURL()
        self.popOrDismissViewControllerAnimated(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
        
    func throwInSea (shore: Shore) {
     
        let urls:[URL] = [self.videoUrl as URL]
        showActivityLoader(true)
        
        // show progresss view
        self.uploadProgressWave.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.uploadProgressWater.frame.height + self.uploadProgressWave.frame.height)
        self.uploadProgressWater.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.uploadProgressWater.frame.height)
        self.uploadProgressWater.isHidden = false
        self.uploadProgressWave.isHidden = false
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.uploadProgressWave.alpha = 1.0
            self.uploadProgressWave.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.uploadProgressWater.frame.height)
        }, completion: {(finished: Bool) in
        })
        
        // monitoring throw a bottle performance
        let trace = Performance.startTrace(name: "Upload & Create new bottle")
        
        ApiManager.shared.uploadMedia(urls: urls, mediaType: .video, completionBlock: { (files, errorMessage) in
//        
            if errorMessage == nil {
        
                let logEventParams = ["Shore": shore.name_en ?? ""];
                Flurry.logEvent(AppConfig.throw_shore_selected, withParameters:logEventParams);
                
                let bottle = Bottle()
                bottle.attachment = files[0].fileUrl ?? " "
                bottle.thumb = files[0].thumbUrl ?? " "
                //bottle.attachment = "http://104.217.253.15:9999/api/uploads/videos/download/1523169457577_0261BAEB-C40E-49DE-A148-2E62190B43F8.MOV"
                bottle.ownerId = DataStore.shared.me?.objectId
                bottle.owner = DataStore.shared.me
                bottle.status = "pending"
                bottle.shoreId = shore.shore_id
                bottle.topicId = self.topicId
        
                ApiManager.shared.addBottle(bottle: bottle, completionBlock: { (success, error, bottle) in
                
                    self.uploadProgressWater.isHidden = true
                    self.uploadProgressWave.isHidden = true
                    
                    trace?.stop()
                    if error == nil {
                        self.showActivityLoader(false)
                        
                        //print("\(bottle?.bottle_id)")
                        // animate views out
                        self.cvShorePicker.animateIn(mode: .animateOutToBottom, delay: 0.3)
                        self.backButton.animateIn(mode: .animateOutToTop, delay: 0.2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // delay 6 second
                            self.performSegue(withIdentifier: "unwindRecordMediaSegue", sender: self)
                            self.popOrDismissViewControllerAnimated(animated: true)
                        }
                    } else {
                        self.showActivityLoader(false)
                        
                        let alertController = UIAlertController(title: "", message: error?.type.errorMessage , preferredStyle: .alert)
                        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                        //print(error?.type.errorMessage)
                    }
                })
            } else {
                self.showActivityLoader(false)
                print(errorMessage ?? "unknown error occured in upload bottle")
                trace?.stop()
                // hide progress view
                self.uploadProgressWater.isHidden = true
                self.uploadProgressWave.isHidden = true
            }
        }, progressBlock:{ (progressPercent) in
            if let percent = progressPercent {
                
                UIView.animate(withDuration: 0.5, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.uploadProgressWater.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.uploadProgressWater.frame.height * CGFloat(1.0 - percent))
                    self.uploadProgressWave.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.uploadProgressWater.frame.height * CGFloat(1.0 - percent))
                }, completion: {(finished: Bool) in
                })
            }
        })
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        
        if let shore = selectedShore, from == .throwBottle  {
            throwInSea(shore: shore)
        } else {
            Flurry.logEvent(AppConfig.reply_shooted);
            self.performSegue(withIdentifier: "unwindToFindBottleSegue", sender: self)
            self.popOrDismissViewControllerAnimated(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "unwindToFindBottleSegue") {
            
//            let nav = segue.destination as! UINavigationController
            let findBottleVC = segue.destination  as! FindBottleViewController
            findBottleVC.myVideoUrl = self.videoUrl
        }
    }
    
    @IBAction func nextAction() {
        
//        if(type == .IMAGE) {
//            LocalStore.sharedInstance.newTwig?.localImage = image
//        } else {
//            LocalStore.sharedInstance.newTwig?.videoUrl = videoUrl
//        }
//        self.performSegue(withIdentifier: "newTwigMediaLocationSegue", sender: nil)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if self.playButton.currentImage == UIImage(named: "ic_play") {
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else if self.playButton.currentImage == UIImage(named: "pause") {
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        }
        vp.playButtonPressed()
    }
}

// shore psicker logic
extension PreviewMediaControl{
    
    func showShorePicker(show: Bool) {
        if show {
            cvShorePicker.isHidden = false
        }else {
            cvShorePicker.isHidden = true
        }
    }
}

// implement uicollection view delegates
extension PreviewMediaControl:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataStore.shared.shores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoreCell", for: indexPath) as! ShoreCell
        cell.shore = DataStore.shared.shores[indexPath.item]
        cell.btnThrow.isUserInteractionEnabled = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedShoreIndex = indexPath.item;
        throwInSea(shore: DataStore.shared.shores[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

extension PreviewMediaControl:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 250, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 16
    }
    
}
