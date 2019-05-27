//
//  CompleteSignupViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 5/17/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import CountryPickerView

class CompleteSignupViewController: AbstractController {
    
    @IBOutlet weak var lblUsernameTitle: UILabel!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var selectCountryButton: UIButton!
    @IBOutlet weak var signupButton: VobbleButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    @IBOutlet weak var termsPrefixLabel: UILabel!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsOrLabel: UILabel!
    @IBOutlet weak var privacyButton: UIButton!
    
    let countryPickerView = CountryPickerView()
    var isMale: Bool = true
    var countryName: String?
    var countryCode: String?
    var startUpViewController: LoginViewController?
    var tempUserInfoHolder: AppUser = AppUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countryPickerView.showPhoneCodeInView = false
        countryPickerView.showCountryCodeInView = true
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        if countryName != nil {
            let country = countryPickerView.getCountryByName(countryName!)
            self.countryName = country?.name ?? ""
            self.countryCode = country?.code ?? ""
            selectCountryButton.setTitle(countryName, for: .normal)
        }
        
    }
    
    override func customizeView() {
        lblUsernameTitle.font = AppFonts.big
        txtUsername.font = AppFonts.xBigBold
        selectCountryButton.titleLabel?.font = AppFonts.big
        termsButton.titleLabel?.font = AppFonts.smallBold
        privacyButton.titleLabel?.font = AppFonts.smallBold
        termsPrefixLabel.font = AppFonts.small
        termsOrLabel.font = AppFonts.small
        
        lblUsernameTitle.text = "SIGNUP_NAME_TITLE".localized
        txtUsername.placeholder = "SIGNUP_NAME_PLACEHOLDER".localized
        signupButton.setTitle("SOCIAL_USER_INFO_DONE".localized, for: .normal)
        maleLabel.text = "MALE".localized
        femaleLabel.text = "FEMALE".localized
        
        termsButton.setTitle("SIGNUP_TERMS".localized, for: .normal)
        privacyButton.setTitle("SIGNUP_PRIVACY".localized, for: .normal)
        termsPrefixLabel.text = "SIGNUP_ACCESSEPT".localized
        termsOrLabel.text = "SIGNUP_AND".localized
    }
    
    func validatation () -> Bool {
        if let uName = txtUsername.text, !uName.isEmpty {
            tempUserInfoHolder.userName = uName
        } else {
            showMessage(message:"SINGUP_VALIDATION_FNAME".localized, type: .warning)
            return false
        }
        
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

}

// MARK:- IBAction
extension CompleteSignupViewController {
    @IBAction func femaleBtnPressed(_ sender: UIButton) {
        femaleButton.alpha = 1
        femaleLabel.alpha = 1
        maleLabel.alpha = 0.5
        maleButton.alpha = 0.5
        
        isMale = false
    }
    
    @IBAction func maleBtnPressed(_ sender: UIButton) {
        maleButton.alpha = 1
        maleLabel.alpha = 1
        femaleLabel.alpha = 0.5
        femaleButton.alpha = 0.5
        
        isMale = true
    }
    
    @IBAction func checkBtnPressed(_ sender: Any) {
        
        if checkButton.isSelected == false  {
            checkButton.isSelected = true
        }
        else {
            checkButton.isSelected = false
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        if validatation() {
            tempUserInfoHolder.countryISOCode = countryCode
            tempUserInfoHolder.gender = isMale ? .male : .female
            tempUserInfoHolder.accountInfoCompleted = true
            tempUserInfoHolder.userName = txtUsername.text ?? ""
            
            self.showActivityLoader(true)
            ApiManager.shared.updateUser(user: tempUserInfoHolder, completionBlock: { (isSuccess, error, user) in
                self.showActivityLoader(false)
                if isSuccess {
                    self.dismiss(animated: true, completion: {
                        self.startUpViewController?.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                    })

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
    
    @IBAction func countryButtonPressed(_ sender: UIButton) {
        countryPickerView.showCountriesList(from: self)
    }
    
    @IBAction func termsOfServiceAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: termsButton)
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginTermsSegue", sender: privacyButton)
    }
}

extension CompleteSignupViewController : CountryPickerViewDelegate , CountryPickerViewDataSource {
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
        self.countryName = country.name
        self.countryCode = country.code
        selectCountryButton.setTitle(countryName, for: .normal)
    }
    
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country]? {
        var countries = [Country]()
        ["SA", "AE", "LB", "SY", "IQ", "KW", "OM", "DZ", "BH", "EG", "JO", "LY", "PS", "QA", "SD"].forEach { code in
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
