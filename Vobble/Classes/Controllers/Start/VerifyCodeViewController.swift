//
//  VerifyCodeViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 5/17/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class VerifyCodeViewController: AbstractController {
    
    @IBOutlet weak var vMain: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblResendCode: UILabel!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnResendCode: UIButton!
    
    @IBOutlet weak var lblTermsPrefix: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var lblTermsOr: UILabel!
    @IBOutlet weak var btnPrivacy: UIButton!
    
    var mobileNumber: String?
    var startUpViewController: LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func customizeView() {
        txtCode.font = AppFonts.xBigBold
        btnResendCode.titleLabel?.font = AppFonts.normalBold
        lblResendCode.font = AppFonts.bigBold
        lblTitle.font = AppFonts.xBig
        
        btnTerms.titleLabel?.font = AppFonts.smallBold
        btnPrivacy.titleLabel?.font = AppFonts.smallBold
        lblTermsPrefix.font = AppFonts.small
        lblTermsOr.font = AppFonts.small
        
        self.btnLogin.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        
        self.btnLogin.setTitle("LOGIN_LOGIN_BTN".localized, for: .normal)
        self.btnResendCode.setTitle("RESEND_CODE".localized, for: .normal)
        self.lblResendCode.text = "RESEND_CODE_TITLE".localized
        self.lblTitle.text = "VERIFICATION_CODE_PAGE_TITLE".localized
        self.lblTermsPrefix.text = "LOGIN_ACCESSEPT".localized
        self.btnTerms.setTitle("LOGIN_TERMS".localized, for: .normal)
        self.btnPrivacy.setTitle("LOGIN_PRIVACY".localized, for: .normal)
        self.lblTermsOr.text = "SIGNUP_AND".localized
    }

}

// MARK:- IBAction
extension VerifyCodeViewController {
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let code = txtCode.text, !code.isEmpty, let number = mobileNumber {
            self.showActivityLoader(true)
            
            ApiManager.shared.loginByPhone(phone: number, code: Int(code) ?? 0, completionBlock: {(isSuccess, error, user) in
                self.showActivityLoader(false)
                
                if isSuccess {
                    if let isCompleted = user?.accountInfoCompleted, isCompleted {
                        self.dismiss(animated: true, completion: {
                            self.startUpViewController?.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                            
                        })
                    }else {
                        self.dismiss(animated: true) {
                            let completeInfoVC = UIStoryboard.startStoryboard.instantiateViewController(withIdentifier: CompleteSignupViewController.className) as! CompleteSignupViewController
                            completeInfoVC.tempUserInfoHolder = user ?? AppUser()
                            completeInfoVC.startUpViewController = self.startUpViewController
                            completeInfoVC.providesPresentationContextTransitionStyle = true
                            completeInfoVC.definesPresentationContext = true
                            completeInfoVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                            self.startUpViewController?.present(completeInfoVC, animated: true, completion: nil)
                        }
                    }
                }else {
                    if let error = error {
                        self.showMessage(message: error.type.errorMessage, type: .error)
                    }
                }

            })
        }else {
            showMessage(message:"LOGIN_VALIDATION_CODE".localized, type: .warning)
        }
    }
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        if let number = mobileNumber {
            
            self.showActivityLoader(true)
            ApiManager.shared.signupByPhone(phone: number, completionBlock: {(isSuccess, error, result) in
                print(result ?? "")
                self.showActivityLoader(false)
                if isSuccess {
                    self.showMessage(message: "CODE_SENT_SUCCESSFULLY".localized, type: .success)
                }else {
                    if let error = error {
                        self.showMessage(message: error.type.errorMessage, type: .error)
                    }
                }
            })
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.startUpViewController?.showView(withType: .startup)
        }
    }
    
    @IBAction func termsOfServiceAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: btnTerms)
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: btnPrivacy)
    }

}
