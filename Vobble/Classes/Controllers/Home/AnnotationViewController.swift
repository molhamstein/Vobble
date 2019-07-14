//
//  AnnotationViewController.swift
//  twigbig
//
//  Created by Molham Mahmoud on 2017/05/01.
//  Copyright (c) 2017 Brain-socket. All rights reserved.
//

import UIKit
import Gecco
import Flurry_iOS_SDK

class AnnotationViewController: SpotlightViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet var lblStep1: UILabel!
    @IBOutlet var lblStep2: UILabel!
    @IBOutlet var lblStep3: UILabel!
    
    @IBOutlet var ivStep1: UIImageView!
    @IBOutlet var ivStep3: UIImageView!
    @IBOutlet var btnClose: UIButton!
    
    // used to detect if the user pressed the find bottle action
    // to trigger the action in the home viewcontroller
    @IBOutlet var btnStep3ActionReciever: UIButton!
    
    var homeViewController: HomeViewController?
    
    var stepIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        delegate = self
        
        // make tutorial repond to pan too
        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func next(_ labelAnimated: Bool) {
        updateAnnotationView(labelAnimated)
        
        let screenSize = UIScreen.main.bounds.size
        switch stepIndex {
        case 0:
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: screenSize.height/2), diameter: 0))
            Flurry.logEvent(AppConfig.tutorial_welcome_show, withParameters:[:]);
        case 1:
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: screenSize.height/2), diameter: 0))
            dispatch_main_after(0.5) {
                self.homeViewController?.tutorialActon1()
            }
            Flurry.logEvent(AppConfig.tutorial_swipe_show, withParameters:[:]);
            Flurry.logEvent(AppConfig.tutorial_welcome_click, withParameters:[:]);
        case 2:
            self.homeViewController?.tutorialActon2()
            dismiss(animated: true, completion: nil)
            Flurry.logEvent(AppConfig.tutorial_swipe_click, withParameters:[:]);
            //spotlightView.move(Spotlight.Oval(center: CGPoint(x: 26, y: 42), diameter: 50), moveType: .disappear)
        case 3:
            self.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: 55, y: screenSize.height - 50), diameter: 105))
            self.btnStep3ActionReciever.frame = CGRect.init(x: 0, y: screenSize.height - 105, width: 110, height: 110)
            self.btnStep3ActionReciever.bringToFront()
            Flurry.logEvent(AppConfig.tutorial_find_show, withParameters:[:]);
            //spotlightView.move(Spotlight.Oval(center: CGPoint(x: 26, y: 42), diameter: 50), moveType: .disappear)
            //dismiss(animated: true, completion: nil)
        case 4:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            self.next(true)
        }
    }
    
    func updateAnnotationView(_ animated: Bool) {
//        annotationViews.enumerated().forEach { index, view in
//        }
        
        self.ivStep3.alpha = 0
        self.lblStep3.alpha = 0
        
        UIView.animate(withDuration: animated ? 0.4 : 0) {
            switch self.stepIndex {
            case 0:
                self.lblStep1.alpha = 1
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 0
                self.lblStep1.text = "tut1_step1".localized
                self.lblStep1.font = AppFonts.xBigBold
                self.ivStep1.alpha = 0
                self.ivStep3.alpha = 1
                self.ivStep1.image = nil
                self.btnStep3ActionReciever.isHidden = true
                //self.ivStep1.transform = CGAffineTransform.identity.translatedBy(x: 70, y: 0)
            case 1:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 1
                self.lblStep3.alpha = 0
                
                self.lblStep2.text = "tut1_step2".localized
                self.lblStep2.font = AppFonts.xBigBold
                self.ivStep3.alpha = 0
                self.ivStep1.alpha = 1
                self.ivStep1.image = UIImage(named:"inst_fav");
                self.ivStep1.transform = CGAffineTransform.identity.translatedBy(x: 70, y: 0)
                self.btnStep3ActionReciever.isHidden = true
            case 2:
                // this is an empty step
                // closing the first tutorial
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 0
                self.ivStep3.alpha = 0
                self.ivStep1.alpha = 0
                self.btnStep3ActionReciever.isHidden = true
            case 3:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 1
                self.ivStep1.alpha = 0
                self.lblStep3.text = "tut2_desc".localized
                self.lblStep3.font = AppFonts.xBigBold
                self.ivStep3.alpha = 0
                self.ivStep3.image = UIImage(named:"try_finding_bottle");
                self.ivStep3.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
                self.btnStep3ActionReciever.isHidden = false
            case 4:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 0
                self.ivStep1.alpha = 0
                self.ivStep1.transform = CGAffineTransform.identity
                self.btnStep3ActionReciever.isHidden = true
            default:
                break
            }
        }
    }
    
    @IBAction func actionClose(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionStep3FindBottle(_ sender: AnyObject){
        homeViewController?.tutorialActon3FindBottle()
        dismiss(animated: true, completion: nil)
        Flurry.logEvent(AppConfig.tutorial_find_click, withParameters:[:]);
    }
}

extension AnnotationViewController: SpotlightViewControllerDelegate {
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        if stepIndex != 4 {
            next(true)
        }
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
}

extension AnnotationViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
