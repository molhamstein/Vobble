//
//  HomeViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class HomeViewController: AbstractController {
    
    // MARK: Properties
    
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable profile
        self.showNavProfileButton = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /// Customize view
    override func customizeView() {
        // add here any viewes intialization code
    }
    
}

