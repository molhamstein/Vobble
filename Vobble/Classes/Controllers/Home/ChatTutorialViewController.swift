//
//  ChatTutorialViewController.swift
//  twigbig
//
//  Created by Molham Mahmoud on 2017/05/01.
//  Copyright (c) 2017 Brain-socket. All rights reserved.
//

import UIKit
import Gecco

class ChatTutorialViewController: SpotlightViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet var lblStep1: UILabel!
    @IBOutlet var lblStep2: UILabel!
    
    var stepIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        delegate = self
        
//        // make tutorial repond to pan too
//        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
//        panRecognizer.delegate = self
//        self.view.addGestureRecognizer(panRecognizer)
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
            let xPos = (AppConfig.currentLanguage == .arabic) ? 70 : UIScreen.main.bounds.width - 70
            //spotlightView.appear(Spotlight.Oval(frame: CGPoint(x: xPos, y: 100, diameter: 100)))
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: xPos, y: 60), diameter: 100))
        case 1:
            dismiss(animated: true, completion: nil)
            //spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: screenSize.height/2), diameter: 0))
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func updateAnnotationView(_ animated: Bool) {
        
        UIView.animate(withDuration: animated ? 0.4 : 0) {
            switch self.stepIndex {
            case 0:
                self.lblStep1.alpha = 1
                self.lblStep2.alpha = 0
                self.lblStep1.text = "TUT_CHAT_1".localized
                self.lblStep1.font = AppFonts.xBigBold
            case 1:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 1
                self.lblStep2.text = "tut1_step2".localized
                self.lblStep2.font = AppFonts.xBigBold
            case 2:
                // this is an empty step
                // closing the first tutorial
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
            case 3:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
            case 4:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
            default:
                break
            }
        }
    }
    
    @IBAction func actionClose(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
}

extension ChatTutorialViewController: SpotlightViewControllerDelegate {
    func spotlightViewControllerWillPresent(_ viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(_ viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(_ viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
}

