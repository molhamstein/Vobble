//
//  StartViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: AbstractController {
    
    // MARK: Properties
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check if user logged in
        if DataStore.shared.isLoggedin {
    
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err:Error = error {
                    self.showMessage(message:err.localizedDescription, type: .error)     
                }
                ApiManager.shared.getShores(completionBlock: { (shores, error) in
                    
                   self.performSegue(withIdentifier: "startHomeSegue", sender: self)
                    
                })
            })
            
        } else {// user not logged in
            
            self.performSegue(withIdentifier: "startLoginSegue", sender: self)
        }
        
    }
    
}

