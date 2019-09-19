//
//  WaveView.swift
//  Vobble
//
//  Created by Bayan on 2/17/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit
import YXWaveView


class WaveView : AbstractNibView , UIGestureRecognizerDelegate{
    
    @IBOutlet var waterView: YXWaveView?
    @IBOutlet var bottle: UIImageView?
    
    private var unSeenNotificationsCount = DataStore.shared.notificationsCenter.map {$0.isSeen == false}.count
    private var lblBadge: UILabel?
    private var viewController: UIViewController?
    public var isBadgeActive = false
    
    func showWave () {
        
        if waterView == nil {
            // Init
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.size.height - 29)
            waterView = YXWaveView(frame: frame, color: UIColor(red: 0.0, green: 175.0/255.0, blue: 255.0/255.0, alpha: 0.8))
            // wave speed (default: 0.6)
            waterView?.waveSpeed = 0.3
            // wave height (default: 5)
            waterView?.waveHeight = 15
            // wave curvature (default: 1.5)
            waterView?.waveCurvature = 1.2
            // Add WaveView
            self.view.addSubview(waterView!)
            // Start wave
            waterView!.start()
            
            // add a second wave view
            waterView = YXWaveView(frame: frame, color: UIColor(red: 0.0, green: 190.0/255.0, blue: 255.0/255.0, alpha: 0.8))
            // wave speed (default: 0.6)
            waterView?.waveSpeed = 0.8
            // wave height (default: 5)
            waterView?.waveHeight = 10
            // wave curvature (default: 1.5)
            waterView?.waveCurvature = 1.8
            // add view
            self.view.addSubview(waterView!)
            waterView?.overView = bottle
            // Start wave
            waterView!.start()
            
            // add badge to the bottle
            lblBadge = UILabel(frame: CGRect(x: 56, y: 12, width: 24, height: 24))
            lblBadge?.text = "\(unSeenNotificationsCount)"
            lblBadge?.textAlignment = .center
            lblBadge?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            lblBadge?.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            lblBadge?.layer.cornerRadius = 12
            lblBadge?.layer.masksToBounds = true
            lblBadge?.isHidden = (unSeenNotificationsCount > 0) ? false : true
            lblBadge?.isHidden = !isBadgeActive
            bottle?.addSubview(lblBadge!)
            
            NotificationCenter.default.addObserver(self, selector: #selector(setNewBadge), name: Notification.Name("ObserveNotificationCenter"), object: nil)
            
            // animate the bottle
            bottle?.transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi/5)).translatedBy(x: self.view.frame.width/3, y: 30)
            UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                self.bottle?.transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi/8)).translatedBy(x: (self.view.frame.width/3)-10, y: 30)
            }, completion: nil)
        }
        
    }
    
    
    public func addTapAction(_ viewController: UIViewController) {
        self.viewController = viewController
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentNotificationVC))
        tap.delegate = self
        self.bottle?.isUserInteractionEnabled = true
        self.bottle?.addGestureRecognizer(tap)
    }
    
    @objc
    fileprivate func presentNotificationVC(){
        let notificationVC = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: NotificationCenterViewController.className)
        notificationVC.providesPresentationContextTransitionStyle = true
        notificationVC.definesPresentationContext = true
        notificationVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        notificationVC.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
        viewController?.present(notificationVC, animated: true, completion: nil)
    }
    
    @objc
    fileprivate func setNewBadge() {
        lblBadge?.text = "\(unSeenNotificationsCount)"
        lblBadge?.isHidden = (unSeenNotificationsCount > 0) ? false : true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tapped")
        presentNotificationVC()
    }
}
