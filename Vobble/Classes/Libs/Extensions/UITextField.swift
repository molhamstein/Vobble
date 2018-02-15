//
//  UITextField.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 6/20/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func appStyle() {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let padding = CGFloat(16.0)
        let border = CALayer()
        let height = CGFloat(1.0)
        border.borderColor = AppColors.grayXDark.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width:  screenWidth - 2 * padding, height: height)
        border.borderWidth = height
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.xSmall
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }

    func appStyle(padding: Int) {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let border = CALayer()
        let height = CGFloat(1.0)
        border.borderColor = AppColors.grayXDark.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width:  screenWidth - 2 * CGFloat(padding), height: height)
        border.borderWidth = height
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.xSmall
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }
}
