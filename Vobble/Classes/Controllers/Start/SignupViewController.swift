//
//  SignupViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import PIDatePicker

class SignupViewController: AbstractController, PIDatePickerDelegate {
    
    // MARK: Properties
    // stages containers
    @IBOutlet weak var signupStage1: UIView!
    @IBOutlet weak var signupStage2: UIView!
    @IBOutlet weak var signupStage3: UIView!
    @IBOutlet weak var signupStage4: UIView!
    
    // stage1
    @IBOutlet weak var stage1label: UILabel!
    @IBOutlet weak var fNamelabel: UILabel!
    @IBOutlet weak var lNamelabel: UILabel!
    @IBOutlet weak var fNameTextField: UITextField!
    @IBOutlet weak var lNameTextField: UITextField!
    
    // stage2
    @IBOutlet weak var stage2label: UILabel!
    @IBOutlet weak var stage2Desc: UILabel!
    @IBOutlet weak var datePicker: PIDatePicker!
    
    // stage3
    @IBOutlet weak var stage3label: UILabel!
    @IBOutlet weak var stage3Desc: UILabel!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    
    // stage4
    @IBOutlet weak var stage4Label: UILabel!
    @IBOutlet weak var stage4Desc: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nextButton: RNLoadingButton!
    @IBOutlet weak var footerView: UIView!
    // page indicator bullets
    @IBOutlet weak var s1Bullet: UIImageView!
    @IBOutlet weak var s2Bullet: UIImageView!
    @IBOutlet weak var s3Bullet: UIImageView!
    @IBOutlet weak var s4Bullet: UIImageView!
    
    var arrayStagesContainers: [UIView] = [UIView]()
    var arrayStagesBullets: [UIImageView] = [UIImageView]()
    
    // Data
    var currentStageIndex: Int = -1
    var isMale: Bool = true
    var birthday: Date = Date()
    var tempUserInfoHolder: AppUser = AppUser()
    var password: String = ""
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavBackButton = true
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
        stage1label.font = AppFonts.big
        fNamelabel.font = AppFonts.xSmallBold
        lNamelabel.font = AppFonts.xSmallBold
        stage2label.font = AppFonts.big
        stage2Desc.font = AppFonts.xSmallBold
        nextButton.titleLabel?.font = AppFonts.normalSemiBold
        stage3label.font = AppFonts.big
        stage3Desc.font = AppFonts.xSmallBold
        maleButton.titleLabel?.font = AppFonts.xSmall
        femaleButton.titleLabel?.font = AppFonts.xSmall
        stage4Label.font = AppFonts.big
        stage4Desc.font = AppFonts.big
        emailLabel.font = AppFonts.xSmallBold
        passwordLabel.font = AppFonts.xSmallBold
        // text field styles
        fNameTextField.appStyle()
        lNameTextField.appStyle()
        emailTextField.appStyle()
        passwordTextField.appStyle()
        // date picker
        datePicker.font = AppFonts.normal
        datePicker.textColor = AppColors.grayXDark
        datePicker.setDate(birthday, animated: false)
        //datePicker.locale = NSLocale.init(localeIdentifier: "en_US")
        datePicker.reloadAllComponents()
        datePicker.delegate = self
        // gender picker
        if AppConfig.currentLanguage == .arabic {
            maleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20)
            femaleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20)
        } else {
            maleButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 20)
            femaleButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 20)
        }
        // set text
        nextButton.setTitle("SINGUP_NEXT".localized, for: .normal)
        nextButton.setTitle("SINGUP_NEXT".localized, for: .highlighted)
        // name
        stage1label.text = "SINGUP_STEP1_TITLE".localized
        fNamelabel.text = "SINGUP_FNAME_TITLE".localized
        lNamelabel.text = "SINGUP_LNAME_TITLE".localized
        fNameTextField.placeholder = "SINGUP_FNAME_PLACEHOLDER".localized
        lNameTextField.placeholder = "SINGUP_LNAME_PLACEHOLDER".localized
        // birthday
        stage2label.text = "SINGUP_STEP2_TITLE".localized
        stage2Desc.text = "SINGUP_STEP2_DESC".localized
        // gender
        stage3label.text = "SINGUP_STEP3_TITLE".localized
        stage3Desc.text = "SINGUP_STEP3_DESC".localized
        maleButton.setTitle("SINGUP_STEP3_MALE".localized, for: .normal)
        femaleButton.setTitle("SINGUP_STEP3_FEMALE".localized, for: .normal)
        // email
        stage4Label.text = "SINGUP_STEP4_TITLE".localized
        stage4Desc.text = "SINGUP_STEP4_DESC".localized
        emailLabel.text = "SINGUP_EMAIL_TITLE".localized
        emailTextField.placeholder = "SINGUP_EMAIL_PLACEHOLDER".localized
        // password
        passwordLabel.text = "SINGUP_PASSWORD_TITLE".localized
        passwordTextField.placeholder = "SINGUP_PASSWORD_PLACEHOLDER".localized
        
        nextButton.hideTextWhenLoading = true
        
        // init stages array
        arrayStagesContainers.append(signupStage1)
        arrayStagesContainers.append(signupStage2)
        arrayStagesContainers.append(signupStage3)
        arrayStagesContainers.append(signupStage4)
        arrayStagesBullets.append(s1Bullet)
        arrayStagesBullets.append(s2Bullet)
        arrayStagesBullets.append(s3Bullet)
        arrayStagesBullets.append(s4Bullet)
        
        nextStageAction(self)
        // set default gender to male
        didSelectGender(sender:maleButton);
    }
    
    override func backButtonAction(_ sender: AnyObject) {
        // hide keyboard
        fNameTextField.resignFirstResponder()
        lNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        // check current stage
        if currentStageIndex == 0 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            backStage()
        }
    }
    
    @IBAction func nextStageAction (_ sender: AnyObject){
        if currentStageIndex >= 3 {
            if self.validateStage4() {
                attempSignup()
            }
        } else {
            var valid = false;
            switch currentStageIndex {
            case -1:
                valid = true
            case 0:
                valid = self.validateStage1()
            case 1:
                valid = self.validateStage2()
            case 2:
                valid = self.validateStage3()
            case 3:
                valid = self.validateStage4()
            default:
                break;
            }
            
            if valid {
                let newStageIndex = currentStageIndex + 1
                switchToStageIndex(newStageIndex)
            }
        }
    }
    
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
            signupStage1.isHidden = false;
            signupStage2.isHidden = true;
            signupStage3.isHidden = true;
            signupStage4.isHidden = true;
            
            signupStage1.animateIn(mode: .animateInFromBottom, delay: 0.2)
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
    
    @IBAction func didSelectGender (sender: UIButton) {
        let tag = sender.tag
        
        if tag == 0 { // male pressed
            maleButton.isSelected = true
            femaleButton.isSelected = false
            isMale = true
        } else { // female
            maleButton.isSelected = false
            femaleButton.isSelected = true
            isMale = false
        }
    }
    
    func birthdayChanged(sender:UIDatePicker){
        birthday = sender.date
    }
    
    func validateStage1() -> Bool{
        
        if let fName = fNameTextField.text, !fName.isEmpty {
            tempUserInfoHolder.userName = fName
        } else {
            showMessage(message:"SINGUP_VALIDATION_FNAME".localized, type: .warning)
            return false
        }
        
        
        return true
    }
    
    func validateStage2() -> Bool{
        
        let calendar = Calendar.current
        let date2yearsOld = calendar.date(byAdding: .year, value: -2, to: Date())
        let date100yearsOld = calendar.date(byAdding: .year, value: 100, to: Date())
        
        if date2yearsOld!.compare(birthday) == .orderedAscending {
            showMessage(message:"SINGUP_VALIDATION_DATE".localized, type: .warning)
            return false
        }
        
        if birthday.compare(date100yearsOld!) == .orderedDescending {
            showMessage(message:"SINGUP_VALIDATION_DATE".localized, type: .warning)
            return false
        }
        
        return true
    }
    
    func validateStage3() -> Bool{
        tempUserInfoHolder.gender = isMale ? .male : .female
        return true
    }
    
    func validateStage4() -> Bool{
        
        // validate email
        if let email = emailTextField.text, !email.isEmpty {
            
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL".localized, type: .warning)
            return false
        }
        
        if emailTextField.text!.isValidEmail() {
            tempUserInfoHolder.email = emailTextField.text!
        } else {
            showMessage(message:"SINGUP_VALIDATION_EMAIL_FORMAT".localized, type: .warning)
            return false
        }
        
        // validate password
        if let psw = passwordTextField.text, !psw.isEmpty {
        } else {
            showMessage(message:"SINGUP_VALIDATION_PASSWORD".localized, type: .warning)
            return false
        }
        
        if passwordTextField.text!.length >= AppConfig.passwordLength {
            password = passwordTextField.text!;
        } else {
            showMessage(message:"SINGUP_VALIDATION_PASSWORD_LENGHTH".localized, type: .warning)
            return false
        }
        
        
        return true
    }
    
    /// Register user
    func attempSignup () {
        // show loader
        nextButton.isLoading = true
        self.view.isUserInteractionEnabled = false
        ApiManager.shared.userSignup(user: tempUserInfoHolder, password: password) { (success: Bool, err: ServerError?, user: AppUser?) in
            // hide loader
            self.nextButton.isLoading = false
            self.view.isUserInteractionEnabled = true
            if success {
                self.performSegue(withIdentifier: "signupVerificationSegue", sender: self)
            } else {
                self.showMessage(message:(err?.type.errorMessage)!, type: .error)
            }
        }
    }
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fNameTextField {
            lNameTextField.becomeFirstResponder()
        } else if textField == lNameTextField {
            lNameTextField.resignFirstResponder()
            nextStageAction(self)
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            emailTextField.resignFirstResponder()
        } else if textField == passwordTextField {
            nextStageAction(self)
            passwordTextField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: PIDatePicker delegate
    func pickerView(_ pickerView: PIDatePicker, didSelectRow row: Int, inComponent component: Int) {
        birthday = pickerView.date
        print(birthday)
    }
}
