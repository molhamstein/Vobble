//
//  PreviewMediaControl.swift
//  twigBIG
//
//  Created by Dania on 6/3/17.
//
//

import AVFoundation

enum MEDIA_TYPE {
    case IMAGE
    case VIDEO
}

class PreviewMediaControl : AbstractController {
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var vOverlay:UIView!
    @IBOutlet weak var cvShorePicker:UICollectionView!
    
    var type:MEDIA_TYPE!
    var isShorePickerVisible: Bool = false
    
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
        if(type == .VIDEO)
        {
            self.avPlayer.play();
        }
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
                btnSubmit.isHidden = true
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
        self.btnSubmit.bringToFront()
        self.vOverlay.bringToFront()
        self.cvShorePicker.bringToFront()
        
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
    
    @IBAction func throwInSea () {
        //self.performUnwind
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
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoreCell", for: indexPath) as! ShoreCell
        //cell.shore = DataStore.shared.shores[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "unwindRecordMediaSegue", sender: self)
        self.popOrDismissViewControllerAnimated(animated: true)
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
