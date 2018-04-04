//
//  PreviewMediaControl.swift
//  twigBIG
//
//  Created by Dania on 6/3/17.
//
//

import AVFoundation
import UIKit

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
    
    var type:MEDIA_TYPE!
    var isShorePickerVisible: Bool = false
    var from: typeOfController = .chatView
    
    var selectedShoreIndex: Int = -1
    
    //Image
    var image = UIImage();
    var imgUrl:String = ""
    
    //Video
    var videoUrl = NSURL();
    var avPlayer = AVPlayer();
    var avPlayerLayer = AVPlayerLayer();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        if(type == .VIDEO) {
            self.avPlayer.play();
        }
        
        if (from == .findBottle) {
            
            cvShorePicker.isHidden = true
            submitButton.isHidden = false
            
        } else if (from == .throwBottle) {
            
            cvShorePicker.isHidden = false
            submitButton.isHidden = true
            
        } else if (from == .chatView) {
            
            cvShorePicker.isHidden = true
            submitButton.isHidden = true
        }
        
        
        // itro animation 
        cvShorePicker.animateIn(mode: .animateInFromBottom, delay: 0.3)
        backButton.animateIn(mode: .animateInFromTop, delay: 0.2)
        
        self.vOverlay.applyGradient(colours: [ AppColors.blackXDarkWithAlpha, AppColors.blackXLightWithAlpha], direction: .vertical)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avPlayer.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    func initViews() {
        
        if(type == .IMAGE) {
            
            if(imgUrl.isEmpty) {
                self.imageView.image = self.image
            } else {
                self.imageView.setImageForURL(imgUrl, placeholder: AppConfig.PlaceHolderImage)
            }
        
//        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PreviewMediaControl.viewTapped(gesture:)))
//        self.view!.addGestureRecognizer(tapGesture)
        } else {
            // the video player
            let item = AVPlayerItem(url: self.videoUrl as URL);
            self.avPlayer = AVPlayer(playerItem: item);
            self.avPlayer.actionAtItemEnd = .none
            self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer);
            NotificationCenter.default.addObserver(self, selector: #selector(PreviewMediaControl.playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem!)
            
            let screenRect: CGRect = UIScreen.main.bounds
            
            self.avPlayerLayer.frame = CGRect(x:0, y:0, width:screenRect.size.width, height:screenRect.size.height)
            self.view.layer.addSublayer(self.avPlayerLayer)
        }
        
        self.backButton.tintColor = UIColor.white
        self.vOverlay.bringToFront()
        self.cvShorePicker.bringToFront()
        self.submitButton.bringToFront()
        
        // regisert the shores picker cells
        let shoreNib = UINib(nibName: "ShoreCell", bundle: nil)
        cvShorePicker.register(shoreNib, forCellWithReuseIdentifier: "ShoreCell")
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.avPlayer.seek(to: kCMTimeZero)
    }
    
//    func viewTapped(gesture: UIGestureRecognizer) {
//        self.dismiss(animated: false, completion: nil)
//    }
    
    @IBAction func dissmiss() {
        //Image
        image = UIImage()
        imgUrl = ""
        //Video
        videoUrl = NSURL()
        avPlayer = AVPlayer();
        avPlayerLayer = AVPlayerLayer();
        
        if(!imgUrl.isEmpty) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func throwInSea (shoreId: Int) {
     
        let urls:[URL] = [self.videoUrl as URL]
        showActivityLoader(true)
//        ApiManager.shared.uploadMedia(urls: urls) { (files, errorMessage) in
        
//            if errorMessage == nil {
        
                let bottle = Bottle()
//                bottle.attachment = files[0].fileUrl ?? " "
                bottle.attachment = "http://104.217.253.15:5000/api/uploads/videos/download/1522571917248_FD1D8580-AF4E-4594-B804-2C1231AC4D5A.MOV"
                bottle.ownerId = DataStore.shared.me?.id
                bottle.status = "active"
                bottle.shoreId = shoreId
        
                
                ApiManager.shared.addBottle(bottle: bottle, completionBlock: { (success, error, bottle) in
                
                    if error == nil {
                        self.showActivityLoader(false)
                        
                        print("\(bottle?.bottle_id)")
                        // animate views out
                        self.cvShorePicker.animateIn(mode: .animateOutToBottom, delay: 0.3)
                        self.backButton.animateIn(mode: .animateOutToTop, delay: 0.2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // delay 6 second
                            self.performSegue(withIdentifier: "unwindRecordMediaSegue", sender: self)
                            self.popOrDismissViewControllerAnimated(animated: true)
                        }
                    } else {
                        self.showActivityLoader(false)
                        
                        print(error?.type.errorMessage)
                    }
                    
                })
                
//            }
//            else {
//                self.showActivityLoader(false)
//                print(errorMessage)
//            }
        
//        }
    
        
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToFindBottleSegue", sender: self)
        self.popOrDismissViewControllerAnimated(animated: true)
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedShoreIndex = indexPath.item;
        throwInSea(shoreId: DataStore.shared.shores[indexPath.item].shore_id!)
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
