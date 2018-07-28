//
//  LoginViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

enum ViewType {
    case login
    case signup
    case countryV
    case socialLoginStep2
}

class LoginViewController: AbstractController, CountryPickerDelegate {
    
    
    @IBOutlet weak var emailtest: UILabel!
    
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
    
    @IBOutlet weak var lblRegisetrButtonPrefix: UILabel!
    @IBOutlet weak var btnLoginRegister: UIButton!
    @IBOutlet weak var lblRegisetrButtonSuffix: UILabel!
    
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
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    // privacy
    @IBOutlet weak var termsPrefixLabel: UILabel!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsOrLabel: UILabel!
    @IBOutlet weak var privacyButton: UIButton!
    // back to login
    @IBOutlet weak var svLoginPrefixLabel: UILabel!
    @IBOutlet weak var svLoginButton: UIButton!
    // country
    @IBOutlet weak var countryView: UIView!
    
    // socialLogin Step 2
    @IBOutlet weak var socialInfoView: UIView!
    @IBOutlet weak var lblSocialInfoWelcome: UILabel!
    @IBOutlet weak var btnSocialInfoMale: UIButton!
    @IBOutlet weak var btnSocialInfoFemale: UIButton!
    @IBOutlet weak var vSocialInfoMale: UIView!
    @IBOutlet weak var vSocialInfoFemale: UIView!
    @IBOutlet weak var btnSocialInfoSelectCountry: UIButton!
    @IBOutlet weak var lblSocialInfoMale: UILabel!
    @IBOutlet weak var lblSocialInfoFemale: UILabel!
    @IBOutlet weak var btnSocialInfoCheckButton: UIButton!
    @IBOutlet weak var btnSocialInfoSubmit: VobbleButton!
    
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
    var countryCode: String?
    
    var isInitialized = false
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DataStore.shared.fetchBaseData()
//        if let m = DataStore.shared.me {
//             self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
//        }
        //hideView(withType: .signup)
        //hideView(withType: .countryV)
        //loginView.dropShadow()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isInitialized {
            // set initial state and hide views to show later with animation
            self.signupView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.signupView.frame.height)
            self.loginView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.loginView.frame.height)
            self.countryView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.countryView.frame.height)
            self.socialInfoView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.socialInfoView.frame.height)
            
            waveSubView.awakeFromNib()
            waveSubView.showWave()
            
            dispatch_main_after(0.7) {
                self.showView(withType: .login)
            }
        }
        //lvEmailLabel.font = AppFonts.big
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isInitialized {
            self.backgroundView.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
            self.loginButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
            self.signupButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        }
        self.isInitialized = true
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        
        // set fonts
        lvEmailLabel.font = AppFonts.big
        lvEmailTextField.font = AppFonts.xBigBold
        lvPasswordLabel.font = AppFonts.big
        lvPasswordTextField.font = AppFonts.xBigBold
        forgetPasswordButton.titleLabel?.font = AppFonts.normal
        lblRegisetrButtonPrefix.font = AppFonts.normal
        btnLoginRegister.titleLabel?.font = AppFonts.normalBold
        lblRegisetrButtonSuffix.font = AppFonts.normal
        //signup
        svEmailLabel.font = AppFonts.big
        svEmailTextField.font = AppFonts.xBigBold
        svPasswordLabel.font = AppFonts.big
        svPasswordTextField.font = AppFonts.xBigBold
        svUserNamelabel.font = AppFonts.big
        svUserNameTextField.font = AppFonts.xBigBold
        termsPrefixLabel.font = AppFonts.small
        termsButton.titleLabel?.font = AppFonts.smallBold
        privacyButton.titleLabel?.font = AppFonts.smallBold
        termsPrefixLabel.font = AppFonts.small
        termsOrLabel.font = AppFonts.small
        svLoginButton.titleLabel?.font = AppFonts.normalBold
        svLoginPrefixLabel.font = AppFonts.normal
        selectCountryButton.titleLabel?.font = AppFonts.big
        
        btnSocialInfoSelectCountry.titleLabel?.font = AppFonts.big
        lblSocialInfoWelcome.font = AppFonts.big
        
        lvEmailLabel.text = "LOGIN_EMAIL_TITLE".localized
        lvEmailTextField.placeholder = "LOGIN_EMAIL_PLACEHOLDER".localized
        lvPasswordLabel.text = "LOGIN_PSW_TITLE".localized
        lvPasswordTextField.placeholder = "LOGIN_PSW_PLACEHOLDER".localized
        forgetPasswordButton.setTitle("LOGIN_FORGOT_PSW".localized, for: .normal)
        loginButton.setTitle("LOGIN_LOGIN_BTN".localized, for: .normal)
        lblRegisetrButtonPrefix.text = "LOGIN_REGISTER_BTN_PREFIX".localized
        btnLoginRegister.setTitle("LOGIN_REGISTER_BTN".localized, for: .normal)
        lblRegisetrButtonSuffix.text = "LOGIN_REGISTER_BTN_SUFFIX".localized
        
        svEmailLabel.text = "SIGNUP_EMAIL_TITLE".localized
        svEmailTextField.placeholder = "SIGNUP_EMAIL_PLACEHOLDER".localized
        svUserNamelabel.text = "SIGNUP_NAME_TITLE".localized
        svUserNameTextField.placeholder = "SIGNUP_NAME_PLACEHOLDER".localized
        svPasswordLabel.text = "SIGNUP_PSW_TITLE".localized
        svPasswordTextField.placeholder = "SIGNUP_PSW_PLACEHOLDER".localized

        termsPrefixLabel.text = "SIGNUP_ACCESSEPT".localized
        termsButton.setTitle("SIGNUP_TERMS".localized, for: .normal)
        privacyButton.setTitle("SIGNUP_PRIVACY".localized, for: .normal)
        termsPrefixLabel.text = "SIGNUP_ACCESSEPT".localized
        termsOrLabel.text = "SIGNUP_AND".localized
        svLoginButton.setTitle("SIGNUP_LOGIN_BTN".localized, for: .normal)
        signupButton.setTitle("SIGNUP_SIGNUP_BTN".localized, for: .normal)
        svLoginPrefixLabel.text = "SIGNUP_LOGIN_BTN_PREFIX".localized
        selectCountryButton.setTitle("SIGNUP_COUNTRY_PLACEHOLDER".localized, for: .normal)
        
        btnSocialInfoSelectCountry.setTitle("SIGNUP_COUNTRY_PLACEHOLDER".localized, for: .normal)

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
    @IBAction func termsOfServiceAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: nil)
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: nil)
    }
    
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
                            
                                Auth.auth().signInAnonymously(completion: { (user, error) in
                                    if let err:Error = error {
                                        self.showMessage(message:err.localizedDescription, type: .error)
                                    }
                                    ApiManager.shared.getShores(completionBlock: { (shores, error) in
                                        
                                        self.loginButton.isLoading = false
                                        self.dismiss(animated: true, completion: { })
                                        self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                                        
                                    })
                                    DataStore.shared.fetchBaseData()
                                })
                                
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
        SocialManager.shared.facebookLogin(controller: self) { (user, isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            
            // login succeed go to home screen
            if (isSuccess) {
                if let tempRegistredUser = user, let name = tempRegistredUser.userName {
                    self.tempUserInfoHolder = tempRegistredUser
                    self.lblSocialInfoWelcome.text = String(format: "SINGUP_SOCIAL_WELCOM".localized, name)
                    self.showView(withType: .socialLoginStep2)
                }
                //self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
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
    
    @IBAction func instagramAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        SocialManager.shared.instagramLogin(controller: self) { (user, isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            // login succeed go to home screen
            if (isSuccess) {
                if let tempRegistredUser = user, let name = tempRegistredUser.userName {
                    self.tempUserInfoHolder = tempRegistredUser
                    self.lblSocialInfoWelcome.text = String(format: "SINGUP_SOCIAL_WELCOM".localized, name)
                    self.showView(withType: .socialLoginStep2)
                }
                //self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
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
    
    @IBAction func googleAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        
        SocialManager.shared.googleLogin(delegateController: self)
        
        
//        GIDSignIn.sharedInstance().clientID = AppConfig.googleClientID
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        
        
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
        
        //GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        //GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        //GIDSignIn.sharedInstance().signInSilently()
    }
    
    
    @IBAction func registerBtnPressed(_ sender: AnyObject) {
        
        /***  register btn in login view  ***/
        //   1 - hide login view
        //   2 - show signup view
        
        hideView(withType: .login)
        dispatch_main_after(0.2) {
            self.showView(withType: .signup)
        }
    }
    
    @IBAction func backToLoginBtnPressed(_ sender: AnyObject) {
        
        /***  register btn in login view  ***/
        //   1 - hide login view
        //   2 - show signup view
        
        self.hideView(withType: .signup)
        dispatch_main_after(0.4) {
            self.showView(withType: .login)
        }
    }
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        
        if validateFields() {
          // show loader
            signupButton.isLoading = true
            self.view.isUserInteractionEnabled = false
            ApiManager.shared.userSignup(user: tempUserInfoHolder, password: password) { (success: Bool, err: ServerError?, user: AppUser?) in
              
                if let email = self.tempUserInfoHolder.email, success {
                
                    ApiManager.shared.userLogin(email: email, password: self.password) { (isSuccess, error, user) in
                        // hide loader
                        self.signupButton.isLoading = false
                        self.view.isUserInteractionEnabled = true
                        // login success
                        if (isSuccess) {
                        
                            Auth.auth().signInAnonymously(completion: { (user, error) in
                                if let err:Error = error {
                                    self.loginButton.isLoading = false
                                    self.showMessage(message:err.localizedDescription, type: .error)
                                }
                                self.loginButton.isLoading = false
                                self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                            })
                        
                        } else {
                            self.showMessage(message:(error?.type.errorMessage)!, type: .error)
                        }
                    }
                    //self.showMessage(message:"success @_@", type: .warning)
                    DataStore.shared.fetchBaseData()
                
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
        btnSocialInfoSelectCountry.setTitle(countryName, for: .normal)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        hideView(withType: .countryV)
        selectCountryButton.setTitle(countryName, for: .normal)
        btnSocialInfoSelectCountry.setTitle(countryName, for: .normal)
    }
    
    @IBAction func countryBtnPressed(_ sender: UIButton) {
        showView(withType: .countryV)
    }
    
    @IBAction func femaleBtnPressed(_ sender: UIButton) {
        
        femaleButton.alpha = 1
        femaleLabel.alpha = 1
        maleLabel.alpha = 0.5
        maleButton.alpha = 0.5
        
        vSocialInfoFemale.alpha = 1
        lblSocialInfoFemale.alpha = 1
        lblSocialInfoMale.alpha = 0.5
        vSocialInfoMale.alpha = 0.5
        
        isMale = false
    }
    
    @IBAction func maleBtnPressed(_ sender: UIButton) {
        
        maleButton.alpha = 1
        maleLabel.alpha = 1
        femaleLabel.alpha = 0.5
        femaleButton.alpha = 0.5
        
        vSocialInfoFemale.alpha = 0.5
        lblSocialInfoFemale.alpha = 0.5
        lblSocialInfoMale.alpha = 1
        vSocialInfoMale.alpha = 1
        
        isMale = true
    }
    
    @IBAction func checkBtnPressed(_ sender: Any) {
        
        if checkButton.isSelected == false  {
            checkButton.isSelected = true
            btnSocialInfoCheckButton.isSelected = true
        }
        else {
            checkButton.isSelected = false
            btnSocialInfoCheckButton.isSelected = false
        }
    }
    
    
    func validateFields () -> Bool {
        
        if !checkButton.isSelected {
            showMessage(message:"SINGUP_VALIDATION_TERMS".localized, type: .warning)
            return false
        }
        
        if let uName = svUserNameTextField.text, !uName.isEmpty {
            tempUserInfoHolder.userName = uName
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
        
        if let countryIsoCode = countryCode {
            tempUserInfoHolder.countryISOCode = countryIsoCode
        } else {
            showMessage(message:"SINGUP_VALIDATION_CHOOSE_COUNTRY".localized, type: .warning)
            return false
        }

        
        return true
    }
    
    func validateSocialLoginStep2Fields () -> Bool {
        
        if !checkButton.isSelected {
            showMessage(message:"SINGUP_VALIDATION_TERMS".localized, type: .warning)
            return false
        }
        
        tempUserInfoHolder.gender = isMale ? .male : .female
        
        if let countryIsoCode = countryCode {
            tempUserInfoHolder.countryISOCode = countryIsoCode
        } else {
            showMessage(message:"SINGUP_VALIDATION_CHOOSE_COUNTRY".localized, type: .warning)
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
            loginView.dropShadow()
            UIView.animate(withDuration: 0.4, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.loginView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            }, completion: {(finished: Bool) in
                
            })
        case .signup :
            signupView.dropShadow()
            UIView.animate(withDuration: 0.4, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.signupView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            }, completion: {(finished: Bool) in
                
            })
        case .countryV :
            signupView.dropShadow()
            UIView.animate(withDuration: 0.4, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.countryView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            }, completion: {(finished: Bool) in
                
            })
        case .socialLoginStep2 :
            socialInfoView.dropShadow()
            UIView.animate(withDuration: 0.4, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.socialInfoView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
            }, completion: {(finished: Bool) in
                
            })
        }
    }
    
    func hideView(withType:ViewType) {
        switch withType {
        case .login :
            UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.loginView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.loginView.frame.height)
            }, completion: {(finished: Bool) in
                
            })
        case .signup :
            UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.signupView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.signupView.frame.height)
            }, completion: {(finished: Bool) in
                
            })
        case .countryV :
            UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.countryView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.countryView.frame.height)
            }, completion: {(finished: Bool) in
                
            })
        case .socialLoginStep2:
            UIView.animate(withDuration: 0.3, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.socialInfoView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.socialInfoView.frame.height)
            }, completion: {(finished: Bool) in
                
            })
        }
    }
    
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        self.countryName = name
        self.countryCode = code
    }
    
    
    // social user registration step 2
    @IBAction func updateSocialUserInfoAction(_ sender: Any) {
            
        if validateSocialLoginStep2Fields() {
            // show loader
            btnSocialInfoSubmit.isLoading = true
            self.view.isUserInteractionEnabled = false

            tempUserInfoHolder.countryISOCode = countryCode
            tempUserInfoHolder.gender = isMale ? .male : .female
            
            ApiManager.shared.updateUser(user: tempUserInfoHolder) { (success: Bool, err: ServerError?, user: AppUser?) in
                self.view.isUserInteractionEnabled = true
                self.btnSocialInfoSubmit.isLoading = false
                if success {
                    self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                } else {
                    self.showMessage(message:(err?.type.errorMessage)!, type: .error)
                }
            }
        }
    }

}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate{
    
    //MARK:Google SignIn Delegate
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        self.showActivityLoader(false)
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //completed sign In
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.showActivityLoader(true)
        SocialManager.shared.googleLoginResult(signIn, didSignInFor: user, withError: error) { (user, success, error) in
            self.showActivityLoader(false)
            if (success) {
                if let tempRegistredUser = user, let name = tempRegistredUser.userName {
                    self.tempUserInfoHolder = tempRegistredUser
                    self.lblSocialInfoWelcome.text = String(format: "SINGUP_SOCIAL_WELCOM".localized, name)
                    self.showView(withType: .socialLoginStep2)
                }
                //self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
            } else {
                let errorServer = error ?? ServerError.unknownError
                // social login failed
                if errorServer.type == ServerError.socialLoginError.type {
                    self.showMessage(message: "ERROR_SOCIAL_GOOGLE", type: .error)
                } else {
                    self.showMessage(message: errorServer.type.errorMessage, type: .error)
                }
            }
        }
    }
    
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
         self.showActivityLoader(false)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
}
