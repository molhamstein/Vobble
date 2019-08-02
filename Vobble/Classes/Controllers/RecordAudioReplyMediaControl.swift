//
//  RecordAudioReplyMediaControl.swift
//  Vobble
//
//  Created by Molham on 7/11/19.
//
//

import AVFoundation
import UIKit
import Flurry_iOS_SDK
import SDRecordButton


class RecordAudioReplyMediaControl : AbstractController {
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var startButton: VobbleButton!
    
    //record
    @IBOutlet var recordButton : SDRecordButton!
    @IBOutlet var vPulseSource : UIView!
    @IBOutlet var lblRecording : UILabel!
    @IBOutlet var lblTimerRecording : UILabel!
    @IBOutlet var recordButtonContainer : UIView!
    
    //
    var isRecording: Bool = false
    var audioUrl: URL? = nil
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    var isAnimating: Bool = false
    var timeOut: Float = 0.0
    var recordTimer: Timer?
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    /// Record beep
    var beepSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "audio_msg_beeb", ofType: "mp3")!)
    var beepPlayer = AVAudioPlayer()
    
    var isVOverlayApplyGradient:Bool = false
    
    var pulseArray = [CAShapeLayer]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false);
        
        // itro animation
        backButton.animateIn(mode: .animateInFromTop, delay: 0.2)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.avPlayer.pause()
    }
    
    override func viewDidLayoutSubviews() {
        if !isVOverlayApplyGradient {
            
            self.recordButtonContainer.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
            
            setupRecorder()
            isVOverlayApplyGradient = true
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    func initViews() {
        
        self.startButton.setTitle("AUDIO_REPLY_START".localized, for: .normal)
        
        // record audio view
        lblRecording.font = AppFonts.bigBold
        lblRecording.text = "AUDIO_REPLY_TITLE".localized
        lblTimerRecording.font = AppFonts.bigBold
        lblTimerRecording.text = "AUDIO_REPLY_RECORD".localized
        
        
        self.backButton.tintColor = UIColor.white
        
//        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didPressRecordAudio(_:)))
//        longGestureRecognizer.minimumPressDuration = 0.3
//        self.startButton.addGestureRecognizer(longGestureRecognizer)
        
        self.startButton.bringToFront()
        
        setupRecorder()
        
        vPulseSource.layer.cornerRadius = vPulseSource.frame.size.width/2.0
        createPulse()
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
//        self.avPlayer.seek(to: kCMTimeZero)
    }
    
    func playBeepSound () {
        // play beep sound
        do {
            // Prepare beep player
            self.beepPlayer = try AVAudioPlayer(contentsOf: beepSound as URL)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            self.beepPlayer.prepareToPlay()
            self.beepPlayer.play()
            
        }catch {}
    }
    
    @IBAction func dissmiss() {
        
        self.popOrDismissViewControllerAnimated(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    // animations
    func createPulse() {
        
        for _ in 0...2 {
            let circularPath = UIBezierPath(arcCenter: .zero, radius: ((self.vPulseSource.superview?.frame.size.width )! )/2, startAngle: 0, endAngle: 2 * .pi , clockwise: true)
            let pulsatingLayer = CAShapeLayer()
            pulsatingLayer.path = circularPath.cgPath
            pulsatingLayer.lineWidth = 2.5
            pulsatingLayer.fillColor = UIColor.clear.cgColor
            pulsatingLayer.lineCap = kCALineCapRound
            pulsatingLayer.position = CGPoint(x: vPulseSource.frame.size.width / 2.0, y: vPulseSource.frame.size.width / 2.0)
            vPulseSource.layer.addSublayer(pulsatingLayer)
            pulseArray.append(pulsatingLayer)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.animatePulsatingLayerAt(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.animatePulsatingLayerAt(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.animatePulsatingLayerAt(index: 2)
                })
            })
        })
    }
    
    
    func animatePulsatingLayerAt(index:Int) {
        
        //Giving color to the layer
        pulseArray[index].strokeColor = UIColor.darkGray.cgColor
        
        //Creating scale animation for the layer, from and to value should be in range of 0.0 to 1.0
        // 0.0 = minimum
        //1.0 = maximum
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 0.9
        
        //Creating opacity animation for the layer, from and to value should be in range of 0.0 to 1.0
        // 0.0 = minimum
        //1.0 = maximum
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0.0
        
        // Grouping both animations and giving animation duration, animation repat count
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, opacityAnimation]
        groupAnimation.duration = 2.3
        groupAnimation.repeatCount = .greatestFiniteMagnitude
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        //adding groupanimation to the layer
        pulseArray[index].add(groupAnimation, forKey: "groupanimation")
        
    }
    
    
    
    func submitReply(_ url: URL) {
        
        Flurry.logEvent(AppConfig.reply_shooted);
        self.performSegue(withIdentifier: "unwindToFindBottleSegue", sender: self)
        self.popOrDismissViewControllerAnimated(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "unwindToFindBottleSegue") {
            
//            let nav = segue.destination as! UINavigationController
            let findBottleVC = segue.destination  as! FindBottleViewController
            findBottleVC.myAudioUrl = self.audioUrl
        }
    }
    
}

//TODO: make custom chat tool bar class
// MARK:- AVAudioRecorderDelegate
extension RecordAudioReplyMediaControl: AVAudioRecorderDelegate {
    
    func didTabRecordAudio(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "", message: "RECORD_LONG_PRESS".localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
        
        self.playBeepSound()
    }
    
    @IBAction func didPressRecordAudio() {
        //print("Long tap is handled")
        if self.isRecording == false {
           
            self.startButton.setTitle("AUDIO_REPLY_STOP".localized, for: .normal)
            
            // pop animation for the button
            UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                    self.startButton.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    self.startButton.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                })
                
            }, completion: { [weak self] (finished) in
                self?.startButton.layer.removeAllAnimations()
            })
            
            self.isRecording = true
            self.playBeepSound()
            
            //write the function for start recording the voice here
            
            self.recordButton.setProgress(0.0)
            
            // reset the timer
            self.recordTimer?.invalidate()
            self.recordTimer = nil;
            // run the timer
            self.recordTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                    target: self,
                                                    selector: #selector(self.tickRecorder(timer:)),
                                                    userInfo: nil,
                                                    repeats: true)
            
            // run the timer
            let runner: RunLoop = RunLoop.current
            runner.add(self.recordTimer!, forMode: .defaultRunLoopMode)
            
            var recordingValid = true
            // we clear sound recorder after every recording session
            // so make sure we have a valid one before recording
            if  self.soundRecorder == nil {
                do {
                    // todo: handle recording permission not granted
                    let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try audioSession.setActive(true)
                    
                    try self.soundRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: self.recordSettings)
                    recordingValid = true
                } catch let error {
                    let errstr = "Error Recording \(error)"
                    print(errstr)
                    let alertController = UIAlertController(title: "", message: errstr, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    recordingValid = false
                }
            }
            if recordingValid {
                self.soundRecorder.prepareToRecord()
                self.soundRecorder.delegate = self
                self.soundRecorder.record()
            }
            
        } else {
            recordTimer?.invalidate()
            stopRecorderTimer()
            recordButton.setProgress(0.0)
            self.playBeepSound()
            self.isRecording = false
            
            self.startButton.setTitle("AUDIO_REPLY_START".localized, for: .normal)
            
            // pop animation for the button
            UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                    self.startButton.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    self.startButton.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                })
            }, completion: { [weak self] (finished) in
                self?.startButton.layer.removeAllAnimations()
            })
            
        }
    }
    
    func setupRecorder(){
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({ [weak self] (granted: Bool)-> Void in
                if granted {
                    //set category and activate recorder session
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try audioSession.setActive(true)
                        //                        if let selfRef = self {
                        //                            try selfRef.soundRecorder = AVAudioRecorder(url: selfRef.directoryURL()!, settings: selfRef.recordSettings)
                        //                        }
                        //                        self?.soundRecorder.prepareToRecord()
                    } catch {
                        print("Error Recording");
                    }
                }
            })
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            let alertController = UIAlertController(title: "", message: "RECORD_FAILED_ERROR".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if let url = audioUrl {
                submitReply(url)
            }
        }
        soundRecorder = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        let alertController = UIAlertController(title: "Audio recording error", message: error?.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("reqsound.m4a")
        audioUrl = soundURL
        return soundURL
    }
    
    // Stop play image
    func tickRecorder(timer:Timer){
        // count down 0
        if (timeOut >= MAX_VIDEO_LENGTH){
            // stop image timer
            recordTimer?.invalidate()
            recordTimer = nil;
            stopRecorderTimer()
        } else {
            timeOut += 0.05;
            self.lblTimerRecording.text = String(format: "%02d", Int(timeOut))
            self.recordButton.setProgress(CGFloat(timeOut/MAX_VIDEO_LENGTH))
        }
    }
    
    func stopRecorderTimer(){
        // stop recording
        self.recordButton.setProgress(0)
        timeOut = 0.0
        if soundRecorder != nil {
            soundRecorder.stop()
        }
    }
}
