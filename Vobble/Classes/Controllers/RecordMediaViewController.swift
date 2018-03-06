//
//  RecordMediaViewController.swift
//  Vobble
//
//  Created by Molham Mahmoud on 3/05/18.
//
//

import LLSimpleCamera
import SDRecordButton

let MAX_VIDEO_LENGTH:Float = 12

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
    
    var videoImageTimer: Timer?
    var recordTimer: Timer?
    var captureMediaType:MEDIA_TYPE = .IMAGE
    
    var settingsButton = UIButton();
    var camera = LLSimpleCamera();
    var timeOut: Float = 0.0
    
    var isAnimating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        prepareForRecording()
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
                }
                else {
                    self.flashButton.isSelected = true
                }
            }
            else {
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
                    
                    let label: UILabel = UILabel(frame: CGRect.zero)
                    label.text = "We need permission for the camera and microphone."
                    label.numberOfLines = 2
                    label.lineBreakMode = .byWordWrapping;
                    label.backgroundColor = UIColor.clear
                    label.font = UIFont(name: "AvenirNext-DemiBold", size: 13.0)
                    label.textColor = UIColor.white
                    label.textAlignment = .center
                    label.sizeToFit()
                    label.center = CGPoint(x: screenRect.size.width / 2.0, y: screenRect.size.height / 2.0)
                    
                    self.errorLabel = label
                    self.view!.addSubview(self.errorLabel)
                    
                    let jumpSettingsBtn: UIButton = UIButton(frame: CGRect(x:50, y:label.frame.origin.y + 50, width:screenRect.size.width - 100, height:50));
                    jumpSettingsBtn.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 24.0)
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
            
        }
        else{
            let label: UILabel = UILabel(frame: CGRect.zero)
            label.text = "You must have a camera to take video."
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping;
            label.backgroundColor = UIColor.clear
            label.font = UIFont(name: "AvenirNext-DemiBold", size: 13.0)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.sizeToFit()
            label.center = CGPoint(x:screenRect.size.width / 2.0, y:screenRect.size.height / 2.0)
            self.errorLabel = label
            self.view!.addSubview(self.errorLabel)
        }
        
        // Configure record button
        let panRec : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecordMediaViewController.didPressRecord(gestureRecognizer:)))
        panRec.cancelsTouchesInView = false
        panRec.delegate = self
        panRec.minimumPressDuration = 0.3
        self.recordButton.addGestureRecognizer(panRec)
        
        let tapRec : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressCapture(gestureRecognizer:)))
        tapRec.cancelsTouchesInView = false
        tapRec.delegate = self
        self.recordButton.addGestureRecognizer(tapRec)
        
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
    
    @IBAction func presentLibraryPicker()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func switchButtonPressed(button: UIButton) {
        if(camera.position == LLCameraPositionRear){
            self.flashButton.isHidden = false;
        }
        else{
            self.flashButton.isHidden = true;
        }
        
        self.camera.togglePosition()
    }
    
    @IBAction func close()
    {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
        let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
        previewControl.type = .IMAGE
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            previewControl.image = editedImage
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            previewControl.image = pickedImage
        }
        self.navigationController?.pushViewController(previewControl, animated: true)
        prepareForRecording()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Record button stuff
extension RecordMediaViewController
{
    func updateTotalMediaDuration() -> Int{
//    _lblStoryDuration.text = [NSString stringWithFormat:@"00:%02d", totalDuration];
//    return totalDuration;
        return 0
    }
    
    func stopRecording()
    {
        videoImageTimer?.invalidate()
        videoImageTimer = nil
        
        if(self.camera.position == LLCameraPositionRear && self.flashButton.isHidden){
            self.flashButton.isHidden = false;
        }
        
        self.switchButton.isHidden = false
        self.camera.stopRecording()
    }
    
    func prepareForRecording(){
        // start the camera
        self.camera.start()
        recordButton.isEnabled = true
        timeOut = 0.0
        isAnimating = false
        recordTimeLabel.text = String(format: "%02d", Int(timeOut))
        recordTimeView.isHidden = true
        recordButton.sendActions(for: .touchUpInside)
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
                    let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
                    previewControl.type = .IMAGE
                    previewControl.image = image ?? UIImage()
                    self.navigationController?.pushViewController(previewControl, animated: true)
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
        }
        else{
            self.camera.mirror = LLCameraMirrorOn
        }
        
        // video type
        captureMediaType = .VIDEO
        recordTimeView.isHidden = false
        
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
        videoImageTimer?.invalidate()
        videoImageTimer = nil
        // run the timer
        videoImageTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(RecordMediaViewController.startRecording(timer:)),
                                               userInfo: nil,
                                               repeats: false)
        
        
        // run the timer
        let runner: RunLoop = RunLoop.current
        runner.add(videoImageTimer!, forMode: .defaultRunLoopMode)
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
        let runner: RunLoop = RunLoop.current
        runner.add(recordTimer!, forMode: .defaultRunLoopMode)
        
        // start  video recorder
        if(self.camera.position == LLCameraPositionRear && !self.flashButton.isHidden){
            self.flashButton.isHidden = true;
        }
        
        self.switchButton.isHidden = true
        self.btnPhotoLibrary.isHidden = true
        // start recording
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent("file")
        let outputURL: URL = url.appendingPathExtension("mp4") as URL
        self.camera.startRecording(withOutputUrl: outputURL, didRecord: {(camera, outputFileUrl, error) -> Void in
            
            if let videoURL = outputFileUrl{
                let data = NSData(contentsOf: videoURL)!
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                self.compressVideo(inputURL: videoURL, outputURL: compressedURL) { (exportSession) in
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
                        print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                        videoUrlForUpload = compressedURL
                    case .failed:
                        break
                    case .cancelled:
                        break
                    }
                    
                    DispatchQueue.main.async {
                        let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
                        previewControl.type = .VIDEO
                        previewControl.videoUrl = videoUrlForUpload as NSURL? ??  NSURL()
                        self.navigationController?.pushViewController(previewControl, animated: true)
                    }
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
            recordTimer?.invalidate()
            recordTimer = nil;
            // stop play image media
            stopRecorderTimer()
            
        }else{// reduce counter
            if (!isAnimating){
                isAnimating = true
                
                UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.calculationModeLinear,.repeat], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { 
                        self.redImageView.alpha = 1.0
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                        self.redImageView.alpha = 0.0
                    })
                }, completion: { (finished) in
                    self.isAnimating = false
                    self.redImageView.layer.removeAllAnimations()
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
        self.recordButton.setProgress(0)
        recordTimeView.isHidden = true
        
        // stop recording
        videoImageTimer?.invalidate()
        videoImageTimer = nil
        
        if(self.camera.position == LLCameraPositionRear && self.flashButton.isHidden){
            self.flashButton.isHidden = false;
        }
        self.btnPhotoLibrary.isHidden = false
        self.switchButton.isHidden = false
        self.camera.stopRecording()
        prepareForRecording()
    }
    
    //MARK: guesture recogniser delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //MARK: Compress recorded Video for upload
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}


