//
//  RateUsPopupViewController.swift
//  Vobble
//
//  Created by Molham mahmoud on 5/18/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class RateUsPopupViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet var lblTopTitle: UILabel!
    @IBOutlet var lblMsg: UILabel!
    @IBOutlet var btnRate: VobbleButton!
    @IBOutlet var btnSkip: UIButton!
    
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRate.setTitle("RATE_US_BTN".localized, for: .normal)
        btnSkip.setTitle("RATE_US_SKIP".localized, for: .normal)
        lblTopTitle.text = "RATE_US_TITLE".localized
        lblMsg.text = "RATE_US_MSG".localized
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
            
        btnRate.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
    }
    
    @IBAction func actionRateUs() {
        if let url = URL(string:"itms-apps://itunes.apple.com/app/" + AppConfig.AppleStoreAppId) {        
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func actionSkip() {
        self.dismiss(animated: true) {}
    }
    
}


