//
//  VerifyCodeViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 5/17/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class VerifyCodeViewController: AbstractController {
    
    @IBOutlet weak var vMain: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
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
    var codeTimer: Timer?
    var counter: Int = 30
    var countryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func customizeView() {
        txtCode.font = AppFonts.xBigBold
        btnResendCode.titleLabel?.font = AppFonts.normalBold
        lblCounter.font = AppFonts.normalBold
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
        
        self.txtCode.delegate = self
    }

    fileprivate func setupTimer(){
        if codeTimer == nil {
            self.codeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            self.counter = 30
            self.btnResendCode.isEnabled = false
            self.btnResendCode.alpha = 0.3
        }else {
            codeTimer?.invalidate()
            codeTimer = nil
            setupTimer()
        }
    }
    
    @objc
    fileprivate func countDown(){
        if counter > 0 {
            self.counter -= 1
            self.lblCounter.text = String(counter)
            self.lblCounter.isHidden = false
        }else {
            self.codeTimer?.invalidate()
            self.codeTimer = nil
            
            self.btnResendCode.alpha = 1
            self.btnResendCode.isEnabled = true
            self.lblCounter.isHidden = true
        }
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
                            completeInfoVC.countryName = self.countryName
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
                    self.setupTimer()
                }else {
                    if let error = error {
                        self.showMessage(message: error.type.errorMessage, type: .error)
                    }
                }
            })
        }
        
        Flurry.logEvent(AppConfig.resend_code)
        
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

// MARK:- Input text delegate
extension VerifyCodeViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            let numberStr: String = string
            let formatter: NumberFormatter = NumberFormatter()
            formatter.locale = Locale(identifier: "en")
            if let final = formatter.number(from: numberStr) {
                textField.text =  "\(textField.text ?? "")\(final)"
            }
            return false
        }
        return true
    }
}
