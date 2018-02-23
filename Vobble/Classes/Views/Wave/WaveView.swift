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
    
    fileprivate var waterView: YXWaveView?
    
    func showWave () {
        
        // Init
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.size.height)
        waterView = YXWaveView(frame: frame, color: UIColor.white)

        // wave speed (default: 0.6)
        waterView?.waveSpeed = 1.0
        
        // wave height (default: 5)
        waterView?.waveHeight = 15
        
        // wave curvature (default: 1.5)
        waterView?.waveCurvature = 1.5
        
        
        // real wave color
        waterView?.realWaveColor = AppColors.blueXLight
        
        // mask wave color
        waterView?.maskWaveColor = AppColors.blueXDark
        
        
        // Add WaveView
        
        self.view.addSubview(waterView!)
        // Start wave
        waterView!.start()
        
        let image = UIImage(named: "bottle-1.png")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: UIScreen.main.bounds.width/2, y: 0, width: imageView.bounds.width, height: imageView.bounds.height)
        self.view.addSubview(imageView)
        
    }
    
}
