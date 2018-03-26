//
//  LoginViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import Firebase

enum ViewType {
    case login
    case signup
    case countryV
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
    @IBOutlet weak var signInButton: GIDSignInButton!
    
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
    
//        if let m = DataStore.shared.me {
//             self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
//        }
        //hideView(withType: .signup)
        //hideView(withType: .countryV)
        //loginView.dropShadow()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        waveSubView.awakeFromNib()
        waveSubView.showWave()
        backgroundView.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        loginButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        signupButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set initial state and hide views to show later with animation
        self.signupView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.signupView.frame.height)
        self.loginView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.loginView.frame.height)
        self.countryView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.countryView.frame.height)
        dispatch_main_after(0.7) {
            self.showView(withType: .login)
        }
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
                            
                                Auth.auth().signInAnonymously(completion: { (user, error) in
                                    if let err:Error = error {
//                                        print(err.localizedDescription)
//                                        self.loginButton.isLoading = false
                                        self.showMessage(message:err.localizedDescription, type: .error)
                                        
                                    }
                                    self.loginButton.isLoading = false
                                    self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
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
    
    @IBAction func googleAction(_ sender: UIButton) {
        // show activity loader
        self.showActivityLoader(true)
        SocialManager.shared.googleLogin(controller: self) { (isSuccess, error) in
            // hide activity loader
            self.showActivityLoader(false)
            // login succeed go to home screen
            if (isSuccess) {
                self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
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
        
        GIDSignIn.sharedInstance().clientID = AppConfig.googleClientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
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
    
    @IBAction func countryBtnPressed(_ sender: UIButton) {
        showView(withType: .countryV)
    }
    
    @IBAction func femaleBtnPressed(_ sender: UIButton) {
        
        femaleButton.alpha = 1
        maleButton.alpha = 0.5
        isMale = false
    }
    
    @IBAction func maleBtnPressed(_ sender: UIButton) {
        
        maleButton.alpha = 1
        femaleButton.alpha = 0.5
        isMale = true
    }
    
    @IBAction func checkBtnPressed(_ sender: Any) {
        
        if checkButton.currentImage == UIImage(named: "checkBox") {
            checkButton.setImage(UIImage(named: "checkBoxActive"), for: .normal)
        }
        else {
            checkButton.setImage(UIImage(named: "checkBox"), for: .normal)
        }
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
        }
    }
    
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        self.countryName = name
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
        self.showActivityLoader(false)
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
         self.showActivityLoader(false)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
}
