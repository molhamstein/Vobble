//
//  LoginViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class LoginViewController: AbstractController {
    
    // MARK: Properties
    // login view
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: RNLoadingButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    // social view
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    // footer view
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
        emailLabel.font = AppFonts.xSmallBold
        passwordLabel.font = AppFonts.xSmallBold
        loginButton.titleLabel?.font = AppFonts.normalSemiBold
        forgetPasswordButton.titleLabel?.font = AppFonts.normal
        socialLabel.font = AppFonts.normal
        signupButton.titleLabel?.font = AppFonts.normalSemiBold
        // text field styles
        emailTextField.appStyle()
        passwordTextField.appStyle()
        // set text
        emailLabel.text = "START_EMAIL_TITLE".localized
        passwordLabel.text = "START_PASSWORD_TITLE".localized
        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .normal)
        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .highlighted)
        loginButton.hideTextWhenLoading = true
        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .normal)
        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .highlighted)
        socialLabel.text = "START_SOCIAL_LOGIN".localized
        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .normal)
        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .highlighted)
        emailTextField.placeholder = "START_EMAIL_PLACEHOLDER".localized
        passwordTextField.placeholder = "START_PASSWORD_PLACEHOLDER".localized
    }
    
    // Build up view elements
    override func buildUp() {
        loginView.animateIn(mode: .animateInFromBottom, delay: 0.2)
        socialView.animateIn(mode: .animateInFromBottom, delay: 0.3)
        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: RNLoadingButton) {
        // validate email
        if let email = emailTextField.text, !email.isEmpty {
            if email.isValidEmail() {
                // validate password
                if let password = passwordTextField.text, !password.isEmpty {
                    if password.length >= AppConfig.passwordLength {
                        // start login process
                        loginButton.isLoading = true
                        self.view.isUserInteractionEnabled = false
                        ApiManager.shared.userLogin(email: email, password: password) { (isSuccess, error, user) in
                            // stop loading
                            self.loginButton.isLoading = false
                            self.view.isUserInteractionEnabled = true
                            // login success
                            if (isSuccess) {
                                // user verified
                                if (DataStore.shared.me?.isVerified)! {
                                    self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                                } else {// need to verify first
                                    self.performSegue(withIdentifier: "loginVerificationSegue", sender: self)
                                }
                            } else {
                                self.showMessage(message:(error?.type.errorMessage)!, type: .error)
                            }
                        }
                    } else {
                        showMessage(message:"SINGUP_VALIDATION_PASSWORD_LENGHTH".localized, type: .warning)
                    }
                } else {
                    showMessage(message:"SINGUP_VALIDATION_PASSWORD".localized, type: .warning)
                }
            } else {
                showMessage(message:"SINGUP_VALIDATION_EMAIL_FORMAT".localized, type: .warning)
            }
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL".localized, type: .warning)
        }
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        // start social facebook login
        SocialManager.shared.facebookLogin(controller: self) { (isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            // login succeed go to home screen
            if (isSuccess) {
                self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
            } else {
                let errorServer = error ?? ServerError.unknownError
                // social login failed
                if errorServer.type == ServerError.socialLoginError.type {
                    self.showMessage(message: "ERROR_SOCIAL_FACEBOOK", type: .error)
                } else {
                    self.showMessage(message: errorServer.type.errorMessage, type: .error)
                }
            }
        }
    }
    
    @IBAction func twitterAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        SocialManager.shared.twitterLogin(controller: self) { (isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            // login succeed go to home screen
            if (isSuccess) {
                self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
            } else {
                let errorServer = error ?? ServerError.unknownError
                // social login failed
                if errorServer.type == ServerError.socialLoginError.type {
                    self.showMessage(message: "ERROR_SOCIAL_TWITTER", type: .error)
                } else {
                    self.showMessage(message: errorServer.type.errorMessage, type: .error)
                }
            }
        }
    }
    
    @IBAction func instagramAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        SocialManager.shared.instagramLogin(controller: self) { (isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            // login succeed go to home screen
            if (isSuccess) {
                self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
            } else {
                let errorServer = error ?? ServerError.unknownError
                // social login failed
                if errorServer.type == ServerError.socialLoginError.type {
                    self.showMessage(message: "ERROR_SOCIAL_INSTAGRAM", type: .error)
                } else {
                    self.showMessage(message: errorServer.type.errorMessage, type: .error)
                }
            }
        }
    }
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            loginAction(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

