//
//  WaveView.swift
//  Vobble
//
//  Created by Bayan on 2/17/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit
import YXWaveView


class WaveView : AbstractNibView {
    
    @IBOutlet var waterView: YXWaveView?
    @IBOutlet var bottle: UIImageView?
    
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
            
            // animate the bottle
            bottle?.transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi/5)).translatedBy(x: self.view.frame.width/3, y: 30)
            UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.bottle?.transform = CGAffineTransform.identity.rotated(by: CGFloat(Double.pi/8)).translatedBy(x: (self.view.frame.width/3)-10, y: 30)
            }, completion: nil)
        }
        
    }
    
}
