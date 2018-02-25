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
        
        // Init
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.size.height - 30)
        waterView = YXWaveView(frame: frame, color: UIColor.white)
        // wave speed (default: 0.6)
        waterView?.waveSpeed = 0.4
        // wave height (default: 5)
        waterView?.waveHeight = 15
        // wave curvature (default: 1.5)
        waterView?.waveCurvature = 1.2
        // real wave color
        waterView?.realWaveColor = AppColors.blueXLight
        // mask wave color
        //waterView?.maskWaveColor = AppColors.blueXDark
        
        
        //let image = UIImage(named: "bottle-1.png")
        //let imageView = UIImageView(image: image!)
        //bottle.frame = CGRect(x: UIScreen.main.bounds.width/2, y: 0, width: imageView.bounds.width, height: imageView.bounds.height)
        //self.view.addSubview(imageView)
        
        
        // Add WaveView
        
        self.view.addSubview(waterView!)
        // Start wave
        waterView!.start()
        

        waterView = YXWaveView(frame: frame, color: UIColor.white)
        // wave speed (default: 0.6)
        waterView?.waveSpeed = 0.8
        // wave height (default: 5)
        waterView?.waveHeight = 10
        // wave curvature (default: 1.5)
        waterView?.waveCurvature = 1.5
        // real wave color
        waterView?.realWaveColor = AppColors.blueXLight
        // mask wave color
        waterView?.maskWaveColor = AppColors.blueXDark
        self.view.addSubview(waterView!)
        // Start wave
        waterView!.start()
        
    }
    
}
