//
//  ShareAppPopupViewController.swift
//  Vobble
//
//  Created by Molham mahmoud on 03/03/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation

class ShareAppPopupViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet var lblTopTitle: UILabel!
    @IBOutlet var lblMsg: UILabel!
    @IBOutlet var btnShare: VobbleButton!
    @IBOutlet var btnSkip: UIButton!
    
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnShare.setTitle("SHARE_APP_BTN".localized, for: .normal)
        btnSkip.setTitle("SHARE_APP_SKIP".localized, for: .normal)
        lblTopTitle.text = "SHARE_APP_TITLE".localized
        lblMsg.text = "SHARE_APP_MSG".localized
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
            
        btnShare.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
    }
    
    @IBAction func actionShareApp() {
        ActionShareText.execute(viewController: self, text: "SETTINGS_SHARE_MSG".localized, sourceView: btnShare)
    }
    
    @IBAction func actionSkip() {
        self.dismiss(animated: true) {}
    }
    
}


