//
//  UIColor.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 6/20/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

extension UIColor{
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    convenience init(hexString : String!) {
        var rgbValue: UInt32 = 0
        
        let scanner = Scanner (string: hexString!)
        scanner.scanLocation = 1
        scanner.scanHexInt32(&rgbValue)
        self.init(rgb: rgbValue)
    }
    
    /**
     Create color from 0 to 255 red/green/blue values with 1 alpha value
     */
    convenience init(red:CGFloat, green:CGFloat, blue:CGFloat) {
        self.init(
            red: red / 255,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /**
     Create color from 0 to 255 red/green/blue/alpha
     */
    convenience init(red:CGFloat, green:CGFloat, blue:CGFloat, andAlpha:CGFloat) {
        self.init(
            red: red / 255,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: andAlpha
        )
    }
    
    class func randomColor() -> UIColor{
        let red = CGFloat(arc4random_uniform(255))
        let green = CGFloat(arc4random_uniform(255))
        let blue = CGFloat(arc4random_uniform(255))
        return UIColor(red: red, green: green, blue: blue)
    }
}
