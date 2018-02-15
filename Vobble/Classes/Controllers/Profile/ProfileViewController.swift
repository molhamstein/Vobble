//
//  ProfileViewController.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation

class ProfileViewController: AbstractController {
    
    // MARK: Properties
    
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable back button
        self.showNavBackButton = true
        // set title
        setNavBarTitleImage(type: .logoAndText)
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
    }
    
    // MARK: Actions
    @IBAction func logoutAction(_ sender: UIButton) {
        ActionLogout.execute()
    }
    
}
