//
//  RecordMediaViewController.swift
//  Vobble
//
//  Created by Molham Mahmoud on 3/05/18.
//
//

import LLSimpleCamera
import SDRecordButton
import Flurry_iOS_SDK

let MAX_VIDEO_LENGTH:Float = 60

enum typeOfController {
    case findBottle
    case throwBottle
    case chatView
}

class RecordMediaViewController: AbstractController {
    
    var errorLabel = UILabel();
    @IBOutlet weak var recordButton : SDRecordButton!
    @IBOutlet weak var recordTimeView: UIView!
    @IBOutlet weak var redImageView: UIImageView!
    @IBOutlet weak var recordTimeLabel: UILabel!
    
    @IBOutlet weak var switchButton : UIButton!
    @IBOutlet weak var flashButton : UIButton!
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var vOverlay:UIView!
    @IBOutlet weak var btnPhotoLibrary:UIButton!
    @IBOutlet weak var topicsTableView:UITableView!
    @IBOutlet weak var btnCancelTopics:UIButton!
    @IBOutlet weak var btnTopics:UIButton!
    
    var videoImageTimer: Timer?
    var recordTimer: Timer?
    var captureMediaType:MEDIA_TYPE = .IMAGE
    var from: typeOfController = .throwBottle
    var selectedShore: Shore?
    
    var settingsButton = UIButton();
    var camera = LLSimpleCamera();
    var timeOut: Float = 0.0
    
    var isAnimating: Bool = false
    var isRecording: Bool = false
    var isCanceled: Bool = false
    
    var topicId: String?
    var topics = DataStore.shared.topics
    
    var showHideTopics: Bool = false {
        didSet {
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if self.showHideTopics {
                    
                    self.topicsTableView.isHidden = false
                    self.btnCancelTopics.isHidden = false
                    self.switchButton.isHidden = true
                    self.btnTopics.isHidden = true
                    
                }else {
                    
                    self.topicsTableView.isHidden = true
                    self.btnCancelTopics.isHidden = true
                    self.switchButton.isHidden = false
                    self.btnTopics.isHidden = self.from == .throwBottle ? false : true
                    
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        prepareForRecording()
        
        // animate in 
        recordButton.animateIn(mode: .animateInFromBottom, delay: 0.45)
        btnPhotoLibrary.animateIn(mode: .animateInFromBottom, delay: 0.3)
        redImageView.animateIn(mode: .animateInFromTop, delay: 0.3)
        recordTimeLabel.animateIn(mode: .animateInFromTop, delay: 0.35)
        
        switchButton.animateIn(mode: .animateInFromTop, delay: 0.3)
        flashButton.animateIn(mode: .animateInFromTop, delay: 0.33)
        closeButton.animateIn(mode: .animateInFromTop, delay: 0.4)
        
        btnCancelTopics.animateIn(mode: .animateInFromBottom, delay: 0.3)
        btnTopics.animateIn(mode: .animateInFromBottom, delay: 0.3)
        topicsTableView.animateIn(mode: .animateInFromBottom, delay: 0.3)
        
        btnPhotoLibrary.isHidden = AppConfig.isProductionBuild
        btnCancelTopics.bringToFront()
        btnTopics.bringToFront()
        topicsTableView.bringToFront()
        
        if from == .throwBottle {
            if topics.count > 0 && !DataStore.shared.topicsShowed {
                self.showHideTopics = true
                
                // Set topics appearance to hidden in the next time
                DataStore.shared.topicsShowed = true
            }else {
                self.showHideTopics = false
            }
        }else {
            self.showHideTopics = false
        }
        
        self.view.semanticContentAttribute = .forceLeftToRight
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.from == .throwBottle && self.isRecording == false {
            self.showHideTopics = false
        }
    }
    
    func applicationDocumentsDirectory()-> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true;
    }
    
    func initViews() {
        // setup topics view
        self.topicsTableView.delegate = self
        self.topicsTableView.dataSource = self
        self.topicsTableView.layer.cornerRadius = 18
        self.topicsTableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.8)
        self.topicsTableView.sectionFooterHeight = 15
        self.topicsTableView.footerView(forSection: 0)?.backgroundColor = UIColor.clear
       
        ApiManager.shared.requestTopics(completionBlock: {data, error in
            if data != nil {
                self.topics = data!
                self.topicsTableView.reloadData()
            }
        })
        
        let screenRect = UIScreen.main.bounds;
        let frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        // camera with precise quality, position and video parameters.
        self.camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionFront, videoEnabled: true)
        // attach to the view
        self.camera.attach(to:self, withFrame: frame)
        self.camera.fixOrientationAfterCapture = true;
        
        self.camera.onDeviceChange = {(camera, device) -> Void in
            if (camera?.isFlashAvailable())! {
                self.flashButton.isHidden = false
                if camera?.flash == LLCameraFlashOff {
                    self.flashButton.isSelected = false
                } else {
                    self.flashButton.isSelected = true
                }
            } else {
                self.flashButton.isHidden = true
            }
        }
        
        self.camera.onError = {(camera, error) -> Void in
            let nserror = error as! NSError
            self.prepareForRecording()
            if (nserror.domain == LLSimpleCameraErrorDomain) {
                if nserror.code == 10 || nserror.code == 11 {
                    if(self.view.subviews.contains(self.errorLabel)){
                        self.errorLabel.removeFromSuperview()
                    }
                    
                    let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 50))
                    label.text = "We need permission for the camera and microphone."
                    label.numberOfLines = 3
                    label.lineBreakMode = .byWordWrapping;
                    label.backgroundColor = UIColor.clear
                    label.font = AppFonts.small
                    label.textColor = UIColor.white
                    label.textAlignment = .center
                    label.sizeToFit()
                    label.center = CGPoint(x: screenRect.size.width / 2.0, y: screenRect.size.height / 2.0)
                    
                    self.errorLabel = label
                    self.view!.addSubview(self.errorLabel)
                    
                    let jumpSettingsBtn: UIButton = UIButton(frame: CGRect(x:50, y:label.frame.origin.y + 84, width:screenRect.size.width - 100, height:50));
                    jumpSettingsBtn.titleLabel!.font = AppFonts.normal
                    jumpSettingsBtn.setTitle("Go Settings", for: .normal);
                    jumpSettingsBtn.setTitleColor(UIColor.white, for: .normal);
                    jumpSettingsBtn.layer.borderColor = UIColor.white.cgColor;
                    jumpSettingsBtn.layer.cornerRadius = 5;
                    jumpSettingsBtn.layer.borderWidth = 2;
                    jumpSettingsBtn.clipsToBounds = true;
                    jumpSettingsBtn.addTarget(self, action: #selector(RecordMediaViewController.jumpSettinsButtonPressed(button:)), for: .touchUpInside);
                    jumpSettingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
                    
                    self.settingsButton = jumpSettingsBtn;
                    
                    self.view!.addSubview(self.settingsButton);
                    
                    self.switchButton.isEnabled = false;
                    self.flashButton.isEnabled = false;
                    self.recordButton.isEnabled = false;
                }
            }
        }
        
        if(LLSimpleCamera.isFrontCameraAvailable() && LLSimpleCamera.isRearCameraAvailable()){
            
            self.recordButton.bringToFront()
            
            //flash button
            self.flashButton.tintColor = UIColor.white
            self.flashButton.isHidden = true;
            //switch camera button
            self.switchButton.tintColor = UIColor.white
            self.switchButton.bringToFront()
            
            // show Cam tutorial on first opening of the record view
            if let tutShowedBefore = DataStore.shared.tutorialCamShowed, !tutShowedBefore {
                DataStore.shared.tutorialCamShowed = true
                dispatch_main_after(2) {
                    
                    let alertController = UIAlertController(title: "", message: "TUT_CAM_1".localized, preferredStyle: .alert)
                    let nextAction = UIAlertAction(title: "TUT_CAM_OK_1".localized, style: .default,  handler: {(alert) in
                        // show step 2
                        let alertController = UIAlertController(title: "", message: "TUT_CAM_2".localized, preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "TUT_CAM_OK_2".localized, style: .default,  handler: nil)
                        alertController.addAction(doneAction)
                        self.present(alertController, animated: true, completion: nil)
                    })
                    alertController.addAction(nextAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
            
        } else {
            let label: UILabel = UILabel(frame: CGRect.zero)
            label.text = "You must have a camera to take video."
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping;
            label.backgroundColor = UIColor.clear
            label.font = AppFonts.small
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.sizeToFit()
            label.center = CGPoint(x:screenRect.size.width / 2.0, y:screenRect.size.height / 2.0)
            self.errorLabel = label
            self.view!.addSubview(self.errorLabel)
        }
        
        // Configure record button
//        let panRec : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecordMediaViewController.didPressRecord(gestureRecognizer:)))
//        panRec.cancelsTouchesInView = false
//        panRec.delegate = self
//        panRec.minimumPressDuration = 0.3
//        self.recordButton.addGestureRecognizer(panRec)
        
        self.recordButton.addTarget(self, action: #selector(RecordMediaViewController.toggleRecord), for: .touchUpInside)
        
        // no capture image
//        let tapRec : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressCapture(gestureRecognizer:)))
//        tapRec.cancelsTouchesInView = false
//        tapRec.delegate = self
//        self.recordButton.addGestureRecognizer(tapRec)
        
        self.vOverlay.bringToFront()
        self.closeButton.tintColor = UIColor.white
        self.btnPhotoLibrary.bringToFront()
    }
    
    func segmentedControlValueChanged(control: UISegmentedControl) {
        print("Segment value changed!")
    }
    
    func cancelButtonPressed(button: UIButton) {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    func jumpSettinsButtonPressed(button: UIButton){
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL);
    }
    
    @IBAction func cancelTopicsPressed(_ sender: UIButton) {
        self.showHideTopics = false
        
    }
    
    @IBAction func topicsPressed(_ sender: UIButton) {
        self.showHideTopics = true
        
    }
    
    @IBAction func presentLibraryPicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func switchButtonPressed(button: UIButton) {
        if(camera.position == LLCameraPositionRear){
            self.flashButton.isHidden = false;
        } else {
            self.flashButton.isHidden = true;
        }
        self.camera.togglePosition()
    }
    
    @IBAction func close() {
        isCanceled = true
        stopRecording()
        self.dismiss(animated: true, completion: nil)
        self.popOrDismissViewControllerAnimated(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.camera.view.frame = self.view.bounds
    }
    
    @IBAction func flashButtonPressed(button: UIButton) {
        if self.camera.flash == LLCameraFlashOff {
            let done: Bool = self.camera.updateFlashMode(LLCameraFlashOn)
            if done {
                self.flashButton.isSelected = true
                self.flashButton.setImage(UIImage(named:"recordFlashActiveIcon"), for: .normal)
            }
        }
        else {
            let done: Bool = self.camera.updateFlashMode(LLCameraFlashOff)
            if done {
                self.flashButton.isSelected = false
                self.flashButton.setImage(UIImage(named:"recordFlashIcon"), for: .normal)
            }
        }
    }
}

extension RecordMediaViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil)
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL{
            self.gotToPreview(videoUrl: videoURL, image: nil)
        }
//        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL, self.from == .throwBottle {
//            self.gotToPreview(videoUrl: videoURL, image: nil)
//            
//        }
//        else if let videoURL = info[UIImagePickerControllerReferenceURL] as? NSURL, self.from == .findBottle {
//            self.gotToPreview(videoUrl: videoURL, image: nil)
//        }
        
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            self.gotToPreview(videoUrl: nil, image: editedImage)
//        } else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.gotToPreview(videoUrl: nil, image: pickedImage)
//        }
        
        prepareForRecording()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Record button stuff
extension RecordMediaViewController
{
    func updateTotalMediaDuration() -> Int {
//    _lblStoryDuration.text = [NSString stringWithFormat:@"00:%02d", totalDuration];
//    return totalDuration;
        return 0
    }
    
    func stopRecording() {
        
        recordTimer?.invalidate()
        recordTimer = nil
        
        if(self.camera.position == LLCameraPositionRear && self.flashButton.isHidden){
            self.flashButton.isHidden = false;
        }
        
        self.switchButton.isHidden = false
        self.btnTopics.isHidden = !(from == .throwBottle)
        self.camera.stopRecording()
        isRecording = false
    }
    
    func prepareForRecording(){
        // start the camera
        self.camera.start()
        isRecording = false
        isCanceled = false
        recordButton.isEnabled = true
        timeOut = 0.0
        isAnimating = false
        recordTimeLabel.text = String(format: "%02d", Int(timeOut))
        recordTimeView.isHidden = true
        //recordButton.sendActions(for: .touchUpInside)
        recordButton.setProgress(CGFloat(0))
        //recordTimeLabel.text = String(format: "00:%2d / 00:%i", Int(timeOut) , MAX_VIDEO_LENGTH)
    }
    
    //Record video
    func didPressRecord(gestureRecognizer :UIGestureRecognizer) {
        if (gestureRecognizer.state == .began){
            startVideoImageTimer()
        }else if(gestureRecognizer.state == .ended){
            stopRecording()
            prepareForRecording()
            recordButton.sendActions(for: .touchUpInside)
        }
    }
    
    func toggleRecord(){
        if isRecording {
            stopRecording()
            prepareForRecording()
            //recordButton.sendActions(for: .touchUpInside)
        } else {
            isRecording = true
            recordButton.sendActions(for: .touchDown)
            startVideoImageTimer()
        }
    }
    
    //snap photo
    func didPressCapture(gestureRecognizer:UIGestureRecognizer) {
        if (gestureRecognizer.state == .ended){
            if(self.camera.position == LLCameraPositionRear){
                self.camera.mirror = LLCameraMirrorOff
            }
            else{
                self.camera.mirror = LLCameraMirrorOn
            }
            recordButton.sendActions(for: .touchUpInside)
            recordButton.isEnabled = false
            // capture
            self.camera.capture({(camera, image, metadata, error) -> Void in
                if (error == nil) {
                    camera?.perform(#selector(NetService.stop), with: nil, afterDelay: 0.2)
                    self.gotToPreview(videoUrl: nil, image: image ?? UIImage())
                    self.prepareForRecording()
                }
                else {
                    print("An error has occured: %@", error?.localizedDescription ?? "")
                    self.prepareForRecording()
                }
            }, exactSeenImage: true)
        }
    }
    
    // Start recording
    func startRecording(timer:Timer){
        if(self.camera.position == LLCameraPositionRear){
            self.camera.mirror = LLCameraMirrorOff
        } else {
            self.camera.mirror = LLCameraMirrorOn
        }
        
        // video type
        captureMediaType = .VIDEO
        recordTimeView.isHidden = false
        self.recordButton.isEnabled = true
        
        // start recording
        if (!self.camera.isRecording){
            startRecordTimer()
        }
    }
    
    //MARK: Timer stuff
    // Start video image timer
    func startVideoImageTimer(){
        // image type
        captureMediaType = .IMAGE
        recordTimeView.isHidden = true
        
        // reset the timer
        recordTimer?.invalidate()
        recordTimer = nil
        // run the timer
        recordTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                               target: self,
                                               selector: #selector(RecordMediaViewController.startRecording(timer:)),
                                               userInfo: nil,
                                               repeats: false)
        
        
        // run the timer
        //let runner: RunLoop = RunLoop.current
//        runner.add(videoImageTimer!, forMode: .defaultRunLoopMode)
    }
    
    // Start record timer
    func startRecordTimer(){
        
        // reset the timer
        recordTimer?.invalidate()
        recordTimer = nil;
        // run the timer
        recordTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                           target: self,
                                           selector: #selector(RecordMediaViewController.tickRecorder(timer:)),
                                           userInfo: nil,
                                           repeats: true)
        
        // run the timer
//        let runner: RunLoop = RunLoop.current
//        runner.add(recordTimer!, forMode: .defaultRunLoopMode)
        
        // start  video recorder
        if(self.camera.position == LLCameraPositionRear && !self.flashButton.isHidden){
            self.flashButton.isHidden = true;
        }
        
        self.switchButton.isHidden = true
        self.btnTopics.isHidden = true
        self.btnPhotoLibrary.isHidden = true
        // start recording
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent("file")
        let outputURL: URL = url.appendingPathExtension("mp4") as URL
        self.camera.startRecording(withOutputUrl: outputURL, didRecord: {(camera, outputFileUrl, error) -> Void in
            
            if let videoURL = outputFileUrl, self.isCanceled == false {
                self.showActivityLoader(true)
                let data = NSData(contentsOf: videoURL)!
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                ActionCompressVideo.execute(inputURL: videoURL, outputURL: compressedURL) { (exportSession) in
                    guard let session = exportSession else {
                        return
                    }
                    // use the original video captured by the camera as the deault Video to upload 
                    // and check if the compression successed then use the copressed video for upload
                    var videoUrlForUpload = outputURL;
                    
                    switch session.status {
                    case .unknown:
                        break
                    case .waiting:
                        break
                    case .exporting:
                        break
                    case .completed:
                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                            return
                        }
                        print("File size after compression: \(Double(Double(compressedData.length) / 1048576.0)) mb")
                        videoUrlForUpload = compressedURL
                    case .failed:
                        break
                    case .cancelled:
                        break
                    }
                    
                    DispatchQueue.main.async {
                        self.gotToPreview(videoUrl: videoUrlForUpload as NSURL? , image: nil)
                    }
                    self.showActivityLoader(false)
                }

                self.stopRecorderTimer()
                self.stopRecording()
            }
        })
    }
    
    // Stop play image
    func tickRecorder(timer:Timer){
        // count down 0
        if (timeOut >= MAX_VIDEO_LENGTH){
            // stop image timer
//            recordTimer?.invalidate()
//            recordTimer = nil;
            
            // stop play image media
            stopRecording()
            prepareForRecording()
            recordButton.sendActions(for: .touchUpInside)
            
        } else {// reduce counter
            if (!isAnimating){
                isAnimating = true
                
                UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.calculationModeLinear,.repeat], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                        self.redImageView.alpha = 1.0
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                        self.redImageView.alpha = 0.0
                    })
                }, completion: { [weak self] (finished) in
                    self?.isAnimating = false
                    self?.redImageView.layer.removeAllAnimations()
                })
            }
            timeOut += 0.05;
            
            recordTimeLabel.text = String(format: "%02d", Int(timeOut))
            self.recordButton.setProgress(CGFloat(timeOut/MAX_VIDEO_LENGTH))
        }
    }
    
    // Stop recorder timer
    func stopRecorderTimer(){
        redImageView.isHidden = false
        self.redImageView.alpha = 1.0
        // stop recording
        self.recordButton.setProgress(CGFloat(0))
        recordTimeView.isHidden = true
        
        // stop recording
        recordTimer?.invalidate()
        recordTimer = nil
        
        if(self.camera.position == LLCameraPositionRear && self.flashButton.isHidden){
            self.flashButton.isHidden = false;
        }
        self.btnPhotoLibrary.isHidden = AppConfig.isProductionBuild ? true:false
        self.switchButton.isHidden = false
        self.btnTopics.isHidden = !(from == .throwBottle)
        self.camera.stopRecording()
        isRecording = false
        prepareForRecording()
    }
    
    //MARK: guesture recogniser delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gotToPreview(videoUrl: NSURL?, image: UIImage?) {
        
        if self.from == .findBottle {
            let logEventParams = ["recordType": "reply"];
            Flurry.logEvent(AppConfig.recorded_video, withParameters:logEventParams);
        } else {
            let logEventParams = ["recordType": "new"];
            Flurry.logEvent(AppConfig.recorded_video, withParameters:logEventParams);
        }
        Flurry.logEvent(AppConfig.recorded_video);

        // those animations are removed as they are being suspected of cause crash reported on firebase "check UIView crashes between 1 Jul nad 14 Jul"
//        // animate Views out
//        redImageView.layer.removeAllAnimations()
//        recordButton.animateIn(mode: .animateOutToBottom, delay: 0.3)
//        //redImageView.animateIn(mode: .animateOutToTop, delay: 0.2)
//        recordTimeLabel.animateIn(mode: .animateOutToTop, delay: 0.2)
//
//        switchButton.animateIn(mode: .animateOutToTop, delay: 0.2)
//        btnTopics.animateIn(mode: .animateOutToTop, delay: 0.2)
//        flashButton.animateIn(mode: .animateOutToTop, delay: 0.23)
//        closeButton.animateIn(mode: .animateOutToTop, delay: 0.2)
//        btnPhotoLibrary.animateIn(mode: .animateOutToBottom, delay: 0.3)
        
        // show preview 
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // delay 6 second
            let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
            if let img = image {
                previewControl.type = .IMAGE
                previewControl.image = img
            }
            
            if let vidUrl = videoUrl {
                previewControl.type = .VIDEO
                previewControl.videoUrl = vidUrl
            }
            previewControl.from = self.from
            previewControl.selectedShore = self.selectedShore
            previewControl.topicId = self.topicId
            previewControl.parentVC = self
            
            self.navigationController?.pushViewController(previewControl, animated: false)
        }
    }
}

//MARK: Topics stuff
extension RecordMediaViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor.clear
        
        // Get the only label in topics table view by its tag
        let topicTitle = cell.viewWithTag(1) as! UILabel
        topicTitle.textColor = AppColors.blueXDark
        
        topicTitle.text = self.topics[indexPath.row].text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.topicId = self.topics[indexPath.row].topicId
        
        self.showHideTopics = false
        
    }
    
}
