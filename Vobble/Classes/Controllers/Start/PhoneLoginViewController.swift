//
//  PhoneLoginViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 5/15/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import CountryPickerView

class PhoneLoginViewController: AbstractController {

    @IBOutlet weak var vMain: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblMobileTitle: UILabel!
    @IBOutlet weak var btnCountryPicker: UIButton!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var lblTermsPrefix: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var lblTermsOr: UILabel!
    @IBOutlet weak var btnPrivacy: UIButton!
    
    let countryPickerView = CountryPickerView()
    var countryName: String = ""
    var countryCode: String?
    var startUpViewController: LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    override func customizeView() {
        txtMobileNumber.font = AppFonts.xBigBold
        lblMobileTitle.font = AppFonts.xBig
        btnCountryPicker.titleLabel?.font = AppFonts.xBigBold
        btnTerms.titleLabel?.font = AppFonts.smallBold
        btnPrivacy.titleLabel?.font = AppFonts.smallBold
        lblTermsPrefix.font = AppFonts.small
        lblTermsOr.font = AppFonts.small
        
        self.btnLogin.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
        
        self.btnLogin.setTitle("LOGIN_LOGIN_BTN".localized, for: .normal)
        self.btnCountryPicker.setTitle("LOGIN_COUNTRY_CODE".localized, for: .normal)
        self.lblMobileTitle.text = "MOBILE_PHONE".localized
        self.lblTermsPrefix.text = "LOGIN_ACCESSEPT".localized
        self.btnTerms.setTitle("LOGIN_TERMS".localized, for: .normal)
        self.btnPrivacy.setTitle("LOGIN_PRIVACY".localized, for: .normal)
        self.lblTermsOr.text = "SIGNUP_AND".localized
        
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = true
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        let country = countryPickerView.getCountryByCode("SA")
        self.countryName = country?.name ?? ""
        self.countryCode = (country?.code ?? "") + " " + (country?.phoneCode ?? "")
        btnCountryPicker.setTitle(countryCode, for: .normal)
    }

}

// MARK:- IBAction
extension PhoneLoginViewController {
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let number = txtMobileNumber.text, !number.isEmpty {
            if let code = countryCode {
                if number.hasPrefix("0") || number.count > 10 || number.count < 5{
                    self.showMessage(message: "LOGIN_INVALID_PHONE".localized, type: .warning)
                    return
                }
                
                let fullMobileNumber = code.components(separatedBy: " ")[1] + number
                
                self.showActivityLoader(true)
                ApiManager.shared.signupByPhone(phone: fullMobileNumber, completionBlock: {(isSuccess, error, result) in
                    print(result ?? "")
                    self.showActivityLoader(false)
                    if isSuccess {
                        self.dismiss(animated: true) {
                            dispatch_main_after(0.3) {
                                let verifyCodeVC = UIStoryboard.startStoryboard.instantiateViewController(withIdentifier: VerifyCodeViewController.className) as! VerifyCodeViewController
                                verifyCodeVC.startUpViewController = self.startUpViewController
                                verifyCodeVC.mobileNumber = fullMobileNumber
                                verifyCodeVC.providesPresentationContextTransitionStyle = true
                                verifyCodeVC.definesPresentationContext = true
                                verifyCodeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                                self.startUpViewController?.present(verifyCodeVC, animated: true, completion: nil)
                            }
                        }
                    }else {
                        if let error = error {
                            self.showMessage(message: error.type.errorMessage, type: .error)
                        }
                    }
                })
            }else {
                self.showMessage(message: "LOGIN_VALIDATION_CODE".localized, type: .warning)
            }
            
        }else {
            self.showMessage(message: "LOGIN_VALIDATION_PHONE".localized, type: .warning)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.startUpViewController?.showView(withType: .startup)
        }
    }
    
    @IBAction func countryButtonPressed(_ sender: UIButton) {
        countryPickerView.showCountriesList(from: self)
    }
    
    @IBAction func termsOfServiceAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: btnTerms)
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: btnPrivacy)
    }
}

extension PhoneLoginViewController : CountryPickerViewDelegate , CountryPickerViewDataSource {
    func closeButtonNavigationItem(in countryPickerView: CountryPickerView) -> UIBarButtonItem? {
        return nil
    }
    
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }
    
    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool? {
        return false
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return " "
    }
    
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool? {
        return true
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        if country.code == "AE" {
            let alert = UIAlertController(title: "GLOBAL_WARNING_TITLE".localized, message: "LOGIN_BY_PHONE_UNAVAILABLE".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CHOOSE_ANOTHER_COUNTRY".localized, style: .default, handler: {_ in
                self.countryPickerView.showCountriesList(from: self)
            }))
            alert.addAction(UIAlertAction(title: "CHOOSE_ANOTHER_METHOD".localized, style: .default, handler: {_ in
                self.dismiss(animated: true) {
                    self.startUpViewController?.showView(withType: .startup)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            self.countryName = country.name
            self.countryCode = country.code + " " + country.phoneCode
            btnCountryPicker.setTitle(countryCode, for: .normal)
        }
        
    }
    
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country]? {
        var countries = [Country]()
        ["SA", "LB", "SY", "IQ", "KW", "OM", "DZ", "BH", "EG", "JO", "LY", "PS", "QA", "SD"].forEach { code in
            if let country = countryPickerView.getCountryByCode(code) {
                countries.append(country)
            }
        }
        return countries
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
        return "PREFERED_COUNTRIES_TITLE".localized
    }
}
