//
//  AnnotationViewController.swift
//  twigbig
//
//  Created by Molham Mahmoud on 2017/05/01.
//  Copyright (c) 2017 Brain-socket. All rights reserved.
//

import UIKit
import Gecco

class AnnotationViewController: SpotlightViewController {
    
    @IBOutlet var annotationViews: [UIView]!
    
    @IBOutlet var lblStep1: UILabel!
    @IBOutlet var lblStep2: UILabel!
    @IBOutlet var lblStep3: UILabel!
    
    @IBOutlet var ivStep1: UIImageView!
    @IBOutlet var ivStep3: UIImageView!
    @IBOutlet var btnClose: UIButton!
    
    var homeViewController: HomeViewController?
    
    var stepIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        delegate = self
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
        case 1:
            spotlightView.appear(Spotlight.Oval(center: CGPoint(x: screenSize.width / 2, y: screenSize.height/2), diameter: 0))
            dispatch_main_after(0.5) {
                self.homeViewController?.tutorialActon1()
            }
        case 2:
            self.homeViewController?.tutorialActon2()
            dismiss(animated: true, completion: nil)
            //spotlightView.move(Spotlight.Oval(center: CGPoint(x: 26, y: 42), diameter: 50), moveType: .disappear)
        case 3:
            self.spotlightView.appear(Spotlight.Oval(center: CGPoint(x: 55, y: screenSize.height - 50), diameter: 105))
            //spotlightView.move(Spotlight.Oval(center: CGPoint(x: 26, y: 42), diameter: 50), moveType: .disappear)
            //dismiss(animated: true, completion: nil)
        case 4:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
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
            case 2:
                // this is an empty step
                // closing the first tutorial
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 0
                self.ivStep3.alpha = 0
                self.ivStep1.alpha = 0
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
            case 4:
                self.lblStep1.alpha = 0
                self.lblStep2.alpha = 0
                self.lblStep3.alpha = 0
                self.ivStep1.alpha = 0
                self.ivStep1.transform = CGAffineTransform.identity
            default:
                break
            }
        }
    }
    
    @IBAction func actionClose(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }

}


extension AnnotationViewController: SpotlightViewControllerDelegate {
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
