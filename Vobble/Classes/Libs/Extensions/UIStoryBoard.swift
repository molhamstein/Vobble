//
//  UIStoryBoard.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation

extension UIStoryboard{
    
    static var mainStoryboard:UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static var startStoryboard:UIStoryboard {
        return UIStoryboard(name: "Start", bundle: nil)
    }
        
    static var profileStoryboard:UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
}
