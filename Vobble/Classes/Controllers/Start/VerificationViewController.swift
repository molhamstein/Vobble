//
//  SignupViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 6/29/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class VerificationViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var viewsContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var submitButton: RNLoadingButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var resendButton: RNLoadingButton!
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavBackButton = true
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
        submitButton.titleLabel?.font = AppFonts.normalSemiBold
        titleLabel.font = AppFonts.big
        codeLabel.font = AppFonts.xSmallBold
        resendButton.titleLabel?.font = AppFonts.normalSemiBold
        // text field styles
        codeTextField.appStyle()
        // set text
        submitButton.setTitle("VERIF_CODE_BUTTON".localized, for: .normal)
        submitButton.setTitle("VERIF_CODE_BUTTON".localized, for: .highlighted)
        titleLabel.text = "SINGUP_STEP5_TITLE".localized
        codeLabel.text = "VERIF_CODE_TITLE".localized
        codeTextField.placeholder = "VERIF_CODE_PLACEHOLDER".localized
        resendButton.setTitle("VERIF_CODE_RESEND".localized, for: .normal)
        resendButton.setTitle("VERIF_CODE_RESEND".localized, for: .highlighted)
        
        submitButton.hideTextWhenLoading = true
        
        viewsContainer.animateIn(mode: .animateInFromBottom, delay: 0.2)
        submitButton.animateIn(mode: .animateInFromBottom, delay: 0.3)
        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
        
    }
    
    override func backButtonAction(_ sender: AnyObject) {
        //_ = self.navigationController?.dismiss(animated: true, completion: {})
        DataStore.shared.logout()
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func resendAction (_ sender: AnyObject){
        requestResendVerificationCode()
    }
    
    @IBAction func submitAction (_ sender: AnyObject){
        attemptVerify()
    }
    
    /// Request for new verification code
    func requestResendVerificationCode() {
        // show loader
        resendButton.isLoading = true
        self.view.isUserInteractionEnabled = false
        ApiManager.shared.requestResendVerify() { (success: Bool, err: ServerError?) in
            // hide loader
            self.resendButton.isLoading = false
            self.view.isUserInteractionEnabled = true
            if success {
                self.showMessage(message: "VERIF_RESEND_SUCCESS".localized, type: .success)
            } else {
                self.showMessage(message:(err?.type.errorMessage)!, type: .error)
            }
        }
    }
    
    /// Attempt verification process
    func attemptVerify() {
        if let code = codeTextField.text, !code.isEmpty {
            // show loader
            submitButton.isLoading = true
            self.view.isUserInteractionEnabled = false
            ApiManager.shared.userVerify(code: code) { (success: Bool, err: ServerError?, user: AppUser?) in
                // hide loader
                self.submitButton.isLoading = false
                self.view.isUserInteractionEnabled = true
                if success {
                    self.dismiss(animated: true, completion: {})
                } else {
                    self.showMessage(message:(err?.type.errorMessage)!, type: .error)
                }
            }
        } else {
            showMessage(message: "VERIF_CODE_EMPTY".localized, type: .warning)
        }
    }
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == codeTextField {
            codeTextField.resignFirstResponder()
            attemptVerify()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

