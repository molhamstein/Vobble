//
//  TestViewController.swift
//  Vobble
//
//  Created by Bayan on 2/17/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

enum ViewType {
    case login
    case signup
}

class TestViewController : AbstractController {
 
    
    @IBOutlet weak var waveSubView: WaveView!
    @IBOutlet weak var loginView: UIStackView!
    @IBOutlet weak var signupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveSubView.showWave()
        hideView(withType: .signup)
        
    }
    
    @IBAction func loginBtnPressed(_ sender: AnyObject) {
        
        if sender.tag == 1 {
            
            /*** login btn in login view  ***/
            // go to next view
            
        } else if sender.tag == 2 {
            
            /*** login btn in signup view  ***/
            // 1 - hide signup view
            // 2 - show login view
            
            hideView(withType: .signup)
            showView(withType: .login)
            
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: AnyObject) {
        
        /***  register btn in login view  ***/
        //   1 - hide login view
        //   2 - show signup view
       
        showView(withType: .signup)
        hideView(withType: .login)
        
        
    }
    
    func showView(withType:ViewType) {
        switch withType {
          case .login :
            loginView.isHidden  = false
          case .signup :
            signupView.isHidden = false
        }
    }
    
    func hideView(withType:ViewType) {
        switch withType {
        case .login :
            loginView.isHidden  = true
        case .signup :
            signupView.isHidden = true
        }
    }
    
}
