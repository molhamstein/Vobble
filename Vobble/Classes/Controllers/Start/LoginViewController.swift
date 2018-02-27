//
//  LoginViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

enum ViewType {
    case login
    case signup
    case countryV
}

class LoginViewController: AbstractController, CountryPickerDelegate {
    
    
    
    // MARK: Properties
    
    //main view
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var waveSubView: WaveView!
    
    // login view
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var lvEmailLabel: UILabel!
    @IBOutlet weak var lvEmailTextField: UITextField!
    @IBOutlet weak var lvPasswordLabel: UILabel!
    @IBOutlet weak var lvPasswordTextField: UITextField!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var loginButton: VobbleButton!
    @IBOutlet weak var registerButton: UIButton!
    
    // signup view
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var svEmailLabel: UILabel!
    @IBOutlet weak var svEmailTextField: UITextField!
    @IBOutlet weak var svUserNamelabel: UILabel!
    @IBOutlet weak var svUserNameTextField: UITextField!
    @IBOutlet weak var svPasswordLabel: UILabel!
    @IBOutlet weak var svPasswordTextField: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var selectCountryButton: UIButton!
    @IBOutlet weak var signupButton: VobbleButton!
   
    // country View
    @IBOutlet weak var countryView: UIView!
    
    // social view
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    // Data
    var tempUserInfoHolder: AppUser = AppUser()
    var password: String = ""
    var isMale: Bool = true
    var countryName: String = ""
    
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveSubView.awakeFromNib()
        waveSubView.showWave()
        hideView(withType: .signup)
        hideView(withType: .countryV)
        loginView.dropShadow()
        backgroundView.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], locations: [0.0, 1.0])
        
       
    
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
//        emailLabel.font = AppFonts.xSmallBold
//        passwordLabel.font = AppFonts.xSmallBold
//        loginButton.titleLabel?.font = AppFonts.normalSemiBold
//        forgetPasswordButton.titleLabel?.font = AppFonts.normal
//        socialLabel.font = AppFonts.normal
//        signupButton.titleLabel?.font = AppFonts.normalSemiBold
//        // text field styles
//        emailTextField.appStyle()
//        passwordTextField.appStyle()
//        // set text
//        emailLabel.text = "START_EMAIL_TITLE".localized
//        passwordLabel.text = "START_PASSWORD_TITLE".localized
//        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .normal)
//        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .highlighted)
//        loginButton.hideTextWhenLoading = true
//        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .normal)
//        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .highlighted)
//        socialLabel.text = "START_SOCIAL_LOGIN".localized
//        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .normal)
//        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .highlighted)
//        emailTextField.placeholder = "START_EMAIL_PLACEHOLDER".localized
//        passwordTextField.placeholder = "START_PASSWORD_PLACEHOLDER".localized
    }
    
    // Build up view elements
    override func buildUp() {
//        loginView.animateIn(mode: .animateInFromBottom, delay: 0.2)
//        socialView.animateIn(mode: .animateInFromBottom, delay: 0.3)
//        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: RNLoadingButton) {
        // validate email
        if let email = lvEmailTextField.text, !email.isEmpty {
            if email.isValidEmail() {
                // validate password
                if let password = lvPasswordTextField.text, !password.isEmpty {
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
                                
                                
                                 self.showMessage(message:"success ^_^", type: .warning)
                                
//                                // user verified
//                                if (DataStore.shared.me?.isVerified)! {
//                                    self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
//                                } else {// need to verify first
//                                    self.performSegue(withIdentifier: "loginVerificationSegue", sender: self)
//                                }
                                
                                
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
    
    @IBAction func registerBtnPressed(_ sender: AnyObject) {
        
        /***  register btn in login view  ***/
        //   1 - hide login view
        //   2 - show signup view
        
        showView(withType: .signup)
        hideView(withType: .login)
        
        
    }
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        
        if validateFields() {
          // show loader
          signupButton.isLoading = true
          self.view.isUserInteractionEnabled = false
          ApiManager.shared.userSignup(user: tempUserInfoHolder, password: password) { (success: Bool, err: ServerError?, user: AppUser?) in
              // hide loader
              self.signupButton.isLoading = false
              self.view.isUserInteractionEnabled = true
              if success {
                 // self.performSegue(withIdentifier: "signupVerificationSegue", sender: self)
                 self.showMessage(message:"success @_@", type: .warning)
                
              } else {
                  self.showMessage(message:(err?.type.errorMessage)!, type: .error)
              }
          }
        }
    }
    
    @IBAction func CancelBtnPressed(_ sender: Any) {
        hideView(withType: .countryV)
    }
    
    
    @IBAction func pickCountryPressed(_ sender: Any) {
         hideView(withType: .countryV)
         selectCountryButton.setTitle(countryName, for: .normal)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
         hideView(withType: .countryV)
         selectCountryButton.setTitle(countryName, for: .normal)
    }
    
    @IBAction func countryBtnPressed(_ sender: Any) {
        showView(withType: .countryV)
    }
    
    
    func validateFields () -> Bool {
        
        if let uName = svUserNameTextField.text, !uName.isEmpty {
            tempUserInfoHolder.firstName = uName
        } else {
            showMessage(message:"SINGUP_VALIDATION_FNAME".localized, type: .warning)
            return false
        }
        
        tempUserInfoHolder.gender = isMale ? .male : .female
        
        // validate email
        if let email = svEmailTextField.text, !email.isEmpty {
            
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL".localized, type: .warning)
            return false
        }
        
        if svEmailTextField.text!.isValidEmail() {
            tempUserInfoHolder.email = svEmailTextField.text!
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL_FORMAT".localized, type: .warning)
            return false
        }
        
        // validate password
        if let psw = svPasswordTextField.text, !psw.isEmpty {
        } else {
            showMessage(message:"SINGUP_VALIDATION_PASSWORD".localized, type: .warning)
            return false
        }
        
        if svPasswordTextField.text!.length >= AppConfig.passwordLength {
            password = svPasswordTextField.text!;
        } else {
            showMessage(message:"SINGUP_VALIDATION_PASSWORD_LENGHTH".localized, type: .warning)
            return false
        }

        
        return true
    }
    
    ////////////////////////////////
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == lvEmailTextField {
            lvPasswordTextField.becomeFirstResponder()
        } else if textField == lvPasswordTextField {
            lvPasswordTextField.resignFirstResponder()
            loginAction(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func showView(withType:ViewType) {
        switch withType {
        case .login :
            loginView.isHidden  = false
            loginView.dropShadow()
        case .signup :
            signupView.isHidden = false
            signupView.dropShadow()
        case .countryV :
            countryView.isHidden = false
        }
    }
    
    func hideView(withType:ViewType) {
        switch withType {
        case .login :
            loginView.isHidden  = true
        case .signup :
            signupView.isHidden = true
        case .countryV :
            countryView.isHidden = true
        }
    }
    
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        self.countryName = name
    }
}

