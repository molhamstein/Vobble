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
            let xPos = (AppConfig.currentLanguage == .arabic) ? 100 : UIScreen.main.bounds.width - 100
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: xPos, y: UIScreen.main.bounds.height - 110), diameter: 130))
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
