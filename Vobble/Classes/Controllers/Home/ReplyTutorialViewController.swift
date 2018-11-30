//
//  ReplyTutorialViewController.swift
//  Vobble
//
//  Created by Molham Mahmoud on 2017/05/01.
//  Copyright (c) 2017 Brain-socket. All rights reserved.
//

import UIKit
import Gecco

class ReplyTutorialViewController: SpotlightViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet var lblStep1: UILabel!
    
    var stepIndex: Int = 0
    var buttonFrame: CGRect?
    
    var findViewController: FindBottleViewController?
    
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
        
        switch stepIndex {
        case 0:
            if var btnFrame = buttonFrame {
                btnFrame.size.width += 30
                btnFrame.size.height += 30
                btnFrame.origin.x -= 15
                btnFrame.origin.y -= 15
                //let buttonCenter = btnFrame.origin.x + btnFrame.size.width/2
                //let xPos = (AppConfig.currentLanguage == .arabic) ? buttonCenter : UIScreen.main.bounds.width - buttonCenter
                //let xPos = buttonCenter
                //let yPos = btnFrame.origin.y - btnFrame.size.height/2
                spotlightView.appear(Spotlight.Oval(frame: btnFrame))
                
                // add button to recieve click
                let btn = UIButton.init(frame: btnFrame)
                btn.addTarget(self, action: #selector(ReplyTutorialViewController.actionReply), for: .touchUpInside);
                self.view.addSubview(btn)
            }
        case 1:
            dismiss(animated: true, completion: nil)
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
                self.lblStep1.text = "TUT_REPLY_1".localized
                self.lblStep1.font = AppFonts.xBigBold
            case 1:
                self.lblStep1.alpha = 0
            default:
                break
            }
        }
    }
    
    @IBAction func actionClose(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
    
    func actionReply(_ sender: AnyObject){
        findViewController?.replyBtnPressed(sender)
        findViewController?.replyButton.setClicked(true)
        dismiss(animated: true, completion: nil)
    }
}

extension ReplyTutorialViewController: SpotlightViewControllerDelegate {
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

