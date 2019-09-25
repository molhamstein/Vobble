//
//  EditUsernameViewController.swift
//  Vobble
//
//  Created by Abd Hayek on 9/2/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class EditUsernameViewController: AbstractController {
    
    @IBOutlet var lblTopTitle: UILabel!
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var btnSubmit: VobbleButton!
    
    public var convViewController: ConversationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTopTitle.text = "EDIT_USER_NAME_TITLE".localized
        txtUsername.placeholder = "USERNAME_PLACEHOLDER".localized
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
        txtUsername.font = AppFonts.xBigBold
        btnSubmit.titleLabel?.font = AppFonts.normalSemiBold
        lblTopTitle.font = AppFonts.xBigBold
    }

    override func viewDidAppear(_ animated: Bool) {
        btnSubmit.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .horizontal)

    }
    
    @IBAction func SubmitAction(_ sender: Any){
        if !(txtUsername.text?.isEmpty)! {
            self.showActivityLoader(true)
            ApiManager.shared.editUsername(username: txtUsername.text!, completionBlock: {(success, error) in
                
                if error == nil {
                    ApiManager.shared.getMe(completionBlock: {_ ,_, _ in
                        self.showActivityLoader(false)
                        self.convViewController?.bottleCollectionView.reloadData()
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    let logEventParams = ["userId": DataStore.shared.me?.objectId ?? "", "username": self.txtUsername.text!];
                    Flurry.logEvent(AppConfig.edit_username, withParameters: logEventParams)
                    
                }else {
                    self.showActivityLoader(false)
                    self.showMessage(message: error?.type.errorMessage ?? "", type: .error)
                }
            })
        }else {
            self.showMessage(message: "SINGUP_VALIDATION_FNAME".localized, type: .error)
        }
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        self.dismiss(animated: true) {}
    }}
