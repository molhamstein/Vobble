//
//  ResetPasswordViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class ResetPasswordViewController: AbstractController {
    
    // MARK: Properties
    
    // main view
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var resetPswView: UIView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    @IBOutlet weak var waveSubView: WaveView!
    
    // stages containers
    @IBOutlet weak var resetStage1: UIView!
    @IBOutlet weak var resetStage2: UIView!
    
    // stage1
    @IBOutlet weak var stage1Label: UILabel!
    @IBOutlet weak var stage1Desc: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    // stage2
    @IBOutlet weak var stage2Label: UILabel!
    @IBOutlet weak var stage2Desc: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var nextButton: RNLoadingButton!
    @IBOutlet weak var footerView: UIView!
    // page indicator bullets
    @IBOutlet weak var s1Bullet: UIImageView!
    @IBOutlet weak var s2Bullet: UIImageView!
    
    @IBOutlet weak var submitButton: VobbleButton!
    
    var arrayStagesContainers: [UIView] = [UIView]()
    var arrayStagesBullets: [UIImageView] = [UIImageView]()
    
    // Data
    var currentStageIndex: Int = 0
    var userEmail: String = ""
    var userCode: String = ""
    var userPassword: String = ""
    
    var isInitialized = false
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.showNavBackButton = true
        
         navigationView.viewcontroller = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetPswView.dropShadow()
        backgroundView.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        nextButton.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isInitialized {
            waveSubView.awakeFromNib()
            waveSubView.showWave()
            isInitialized = true
        }
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
//        // set fonts
        emailLabel.font = AppFonts.big
        emailTextField.font = AppFonts.xBigBold
        
//        stage1Desc.font = AppFonts.small
//        stage2Label.font = AppFonts.big
//        stage2Desc.font = AppFonts.small
//        codeLabel.font = AppFonts.xSmallBold
//        passwordLabel.font = AppFonts.xSmallBold
//        nextButton.titleLabel?.font = AppFonts.normalSemiBold
//        // set text
//        stage1Label.text = "RESET_STEP1_TITLE".localized
//        stage1Desc.text = "RESET_STEP1_DESC".localized
//        emailLabel.text = "SINGUP_EMAIL_TITLE".localized
        navigationView.title = "RESET_STEP1_TITLE".localized
        emailLabel.text = "LOGIN_EMAIL_TITLE".localized
        emailTextField.placeholder = "LOGIN_EMAIL_PLACEHOLDER".localized
        nextButton.setTitle("RESET_ACTION_NEXT".localized, for: .normal)
        nextButton.setTitle("RESET_ACTION_NEXT".localized, for: .highlighted)

//        stage2Label.text = "RESET_STEP1_TITLE".localized
//        stage2Desc.text = "RESET_STEP2_DESC".localized
//        codeLabel.text = "RESET_CODE_TITLE".localized
//        codeTextField.placeholder = "RESET_CODE_PLACEHOLDER".localized
//        passwordLabel.text = "RESET_PASSWORD_TITLE".localized
//        passwordTextField.placeholder = "RESET_PASSWORD_PLACEHOLDER".localized
//        nextButton.setTitle("RESET_ACTION_NEXT".localized, for: .normal)
//        nextButton.setTitle("RESET_ACTION_NEXT".localized, for: .highlighted)
//        nextButton.hideTextWhenLoading = true
//        // text field styles
//        emailTextField.appStyle()
//        codeTextField.appStyle()
//        passwordTextField.appStyle()
//        // init stages array
//        arrayStagesContainers.append(resetStage1)
//        arrayStagesContainers.append(resetStage2)
//        arrayStagesBullets.append(s1Bullet)
//        arrayStagesBullets.append(s2Bullet)
//        // start first stage
//        nextStageAction(nextButton)
    }
    
//    override func backButtonAction(_ sender: AnyObject) {
//        // hide keyboard
////        emailTextField.resignFirstResponder()
////        codeTextField.resignFirstResponder()
////        passwordTextField.resignFirstResponder()
////        if currentStageIndex == 0 {
////            _ = self.navigationController?.popViewController(animated: true)
////        } else {
////            backStage()
////        }
//    }
    
    // MARK: Actions
    @IBAction func nextStageAction (_ sender: AnyObject) {
        // hide keyboard
        emailTextField.resignFirstResponder()
//        codeTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
        switch currentStageIndex {
        case -1:
            switchToStageIndex(0)
        case 0:
            if self.validateStage1() {
                forgetPassword()
            }
            break;
        case 1:
            if self.validateStage2() {
                confirmForgetPassword()
            }
            break;
        default:
            break;
        }
    }
    
    // MARK: Controller Logic
    func backStage() {
        let previousStageIndex = currentStageIndex - 1
        switchToStageIndex(previousStageIndex)
    }
    
    func switchToStageIndex(_ index: Int) {
        
        if index  >= arrayStagesContainers.count {
            return
        }
        
        // this is the initial stage switching
        if currentStageIndex == -1 && index == 0 {
            resetStage1.isHidden = false;
            resetStage2.isHidden = true;
            
            resetStage1.animateIn(mode: .animateInFromBottom, delay: 0.2)
            nextButton.animateIn(mode: .animateInFromBottom, delay: 0.3)
            footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
            
        } else {
            if currentStageIndex > index {
                // moving back
                let currentStageView = arrayStagesContainers[currentStageIndex]
                let previousStageView = arrayStagesContainers[index]
                
                currentStageView.animateIn(mode: .animateOutToRight, delay: 0.2)
                previousStageView.animateIn(mode: .animateInFromLeft, delay: 0.3)
            } else {
                // moving next
                let currentStageView = arrayStagesContainers[currentStageIndex]
                let nextStageView = arrayStagesContainers[index]
                
                nextStageView.isHidden = false;
                
                currentStageView.animateIn(mode: .animateOutToLeft, delay: 0.2)
                nextStageView.animateIn(mode: .animateInFromRight, delay: 0.3)
            }
        }
        
        // UPDAET PAGE INDICATOR
        let newbullet = arrayStagesBullets[index]
        newbullet.image = UIImage(named: "icRadioButtonActive")
        if currentStageIndex >= 0 {
            let currentbullet = arrayStagesBullets[currentStageIndex]
            currentbullet.image = UIImage(named: "icRadioButton")
        }
        
        currentStageIndex = index
    }
    
    func validateStage1() -> Bool{
        // check empty email address
        if let email = emailTextField.text, !email.isEmpty {
            // vaild email format
            if email.isValidEmail() {
                self.userEmail = email
                return true
            } else {
                showMessage(message:"SINGUP_VALIDATION_EMAIL_FORMAT".localized, type: .warning)
            }
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL".localized, type: .warning)
        }
        return false
    }
    
    func validateStage2() -> Bool{
        // check empty verification code
        if let code = codeTextField.text, !code.isEmpty {
            userCode = code
            // check empty password
            if let psw = passwordTextField.text, !psw.isEmpty {
                // check password length
                if passwordTextField.text!.length >= AppConfig.passwordLength {
                    userPassword = passwordTextField.text!
                    return true
                } else {
                    showMessage(message:"SINGUP_VALIDATION_PASSWORD_LENGHTH".localized, type: .warning)
                }
            } else {
                showMessage(message:"SINGUP_VALIDATION_PASSWORD".localized, type: .warning)
            }
        } else {
            showMessage(message:"SINGUP_VALIDATION_VERIF_CODE".localized, type: .warning)
        }
        return false
    }
    
    @IBAction func forgetPassword () {
        // start loader
        nextButton.isLoading = true
        self.view.isUserInteractionEnabled = false
        ApiManager.shared.forgetPassword(email: userEmail) { (success: Bool, err: ServerError?) in
            // stop loader
            self.nextButton.isLoading = false
            self.view.isUserInteractionEnabled = true
            if (success) {
                //let newStageIndex = self.currentStageIndex + 1
                //self.switchToStageIndex(newStageIndex)
                let alertController = UIAlertController(title: "", message: "FORGOT_PASSWORD_LINK_SENT".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                    // back to login
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.showMessage(message:(err?.type.errorMessage)!, type: .error)
            }
        }
    }
    
    func confirmForgetPassword () {
        // start loader
        nextButton.isLoading = true
        self.view.isUserInteractionEnabled = false
        ApiManager.shared.confirmForgetPassword(email: userEmail, code: userCode, password: userPassword) { (success: Bool, err: ServerError?) in
            // stop loader
            self.nextButton.isLoading = false
            self.view.isUserInteractionEnabled = true
            if (success) {
                //self.performSegue(withIdentifier: "resetPasswordHomeSegue", sender: self)
                self.dismiss(animated: true, completion: {})
            } else {
                self.showMessage(message:(err?.type.errorMessage)!, type: .error)
            }
        }
    }
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            nextStageAction(nextButton)
        } else if textField == codeTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            nextStageAction(nextButton)
            passwordTextField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

