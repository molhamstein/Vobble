//
//  FilterView.swift
//  Vobble
//
//  Created by Bayan on 3/11/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK
import CountryPickerView

protocol FilterViewDelegate {
    
    func filterViewGet(_ filterView: FilterView, gender: String, country: String)
    func filterViewShowBuyFilterMessage(_ filterView: FilterView, type:ShopItemType)
    func filterViewFindBottle(_ filterView: FilterView)
    func filterViewGoToShop(_ filterView: FilterView, productType: ShopItemType)
}

class FilterView: AbstractNibView {
 
    var delegate: FilterViewDelegate?
    
    @IBOutlet weak var allGenderButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var allGenderLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var genderFilterStackView: UIStackView!
    @IBOutlet weak var genderTimerStackView: UIStackView!
    @IBOutlet weak var genderTimer: TimerLabel!
    @IBOutlet weak var genderLeftLabel: UILabel!
    @IBOutlet weak var genderFilterTitle: UILabel!
    @IBOutlet weak var genderBuyFilterButton: UIButton!
    
    @IBOutlet weak var vGenderPlaceholder: UIView!
    @IBOutlet weak var lblGenderPlaceholder: UILabel!
    
    @IBOutlet weak var countryTimerStackView: UIStackView!
    @IBOutlet weak var countryFilterStackView: UIStackView!
    @IBOutlet weak var countryTimer: TimerLabel!
    @IBOutlet weak var countryLeftLabel: UILabel!
    @IBOutlet weak var countryFilterTitle: UILabel!
    @IBOutlet weak var countryBuyFilterButton: UIButton!
    //@IBOutlet weak var countryPicker: CountryPicker!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var countryPickerOverlay: UIView!
    @IBOutlet weak var countryPickerLabel: UILabel!
    @IBOutlet weak var countryPickerClear: UIButton!
    @IBOutlet weak var genderPicker: UIView!
    
    @IBOutlet weak var vCountryPlaceholder: UIView!
    @IBOutlet weak var lblCountryPlaceholder: UILabel!
    
    @IBOutlet weak var btnFindBottle: UIButton!
    
    fileprivate var selectedGender: String = GenderType.allGender.rawValue
    fileprivate var selectedCountry: String = AppConfig.NO_COUNTRY_SELECTED
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView () {
        // Wording
        allGenderLabel.text = "ALL_GENDER".localized
        maleLabel.text = "MALE".localized
        femaleLabel.text = "FEMALE".localized
        countryFilterTitle.text = "FILTERS_PANEL_COUNTRY_TITLE".localized
        genderFilterTitle.text = "FILTERS_PANEL_GENDER_TITLE".localized
        genderBuyFilterButton.setTitle("FILTERS_PANEL_GENDER_BUY_BTN".localized, for: .normal)
        countryBuyFilterButton.setTitle("FILTERS_PANEL_COUNTRY_BUY_BTN".localized, for: .normal)
        btnFindBottle.setTitle("FILTERS_PANEL_FILTER_NOW_BTN".localized, for: .normal)
        lblCountryPlaceholder.text = "FILTERS_PANEL_PLACEHOLDER_COUNTRY".localized
        lblGenderPlaceholder.text = "FILTERS_PANEL_PLACEHOLDER_GENDER".localized
        countryPickerLabel.text = "FILTERS_PANEL_NO_COUNTRY_SELECTED".localized
        
        // fonts
        allGenderLabel.font = AppFonts.normal
        maleLabel.font = AppFonts.normal
        femaleLabel.font = AppFonts.normal
        countryFilterTitle.font = AppFonts.normalBold
        genderFilterTitle.font = AppFonts.normalBold
        genderBuyFilterButton.titleLabel?.font = AppFonts.xSmall
        countryBuyFilterButton.titleLabel?.font = AppFonts.xSmall
        lblCountryPlaceholder.font = AppFonts.normal
        lblGenderPlaceholder.font = AppFonts.normal
        countryPickerLabel.font = AppFonts.xBigBold
        
        allGenderButton.alpha = 1
        allGenderLabel.alpha = 1
        
        countryPicker.showPhoneCodeInView = false
        countryPicker.showCountryCodeInView = true
        countryPicker.delegate = self
        countryPicker.dataSource = self
        countryPickerOverlay.isHidden = selectedCountry != AppConfig.NO_COUNTRY_SELECTED
        
        refreshFilterView()
    }
    
    func refreshFilterView() {
        genderTimerStackView.isHidden = true
        countryTimerStackView.isHidden = true

        btnFindBottle.isEnabled = false
        btnFindBottle.alpha = 0.5
        
        if DataStore.shared.inventoryItems.filter({$0.type == .genderFilter}).count > 0 {
            let items = DataStore.shared.inventoryItems.filter({$0.type == .genderFilter})
            genderTimerStackView.isHidden = false
            genderFilterStackView.isHidden = true
            
            if let fTime = DataStore.shared.inventoryItems.filter({$0.type == .genderFilter})[items.count - 1].endDate {
                let currentDate = Date().timeIntervalSince1970
                let seconds = (fTime - currentDate)
                
                if seconds >= 0 {
                    genderTimer.resetTimer(seconds: seconds)
                    genderTimer.startTimer(seconds: TimeInterval(seconds))
                    genderTimer.delegate = self
                    //genderPicker.isUserInteractionEnabled = true
                    vGenderPlaceholder.isHidden = true
                    genderTimerStackView.isHidden = false
                    btnFindBottle.isEnabled = true
                    btnFindBottle.alpha = 1.0
                    
                }else{
                    vGenderPlaceholder.isHidden = false
                    genderTimerStackView.isHidden = true
                }
                
            } else {
                vGenderPlaceholder.isHidden = false
                genderTimerStackView.isHidden = true
            }
        }
        
        if DataStore.shared.inventoryItems.filter({$0.type == .countryFilter}).count > 0 {
            let items = DataStore.shared.inventoryItems.filter({$0.type == .countryFilter})
            countryTimerStackView.isHidden = false
            countryFilterStackView.isHidden = true
            
            if let fTime = DataStore.shared.inventoryItems.filter({$0.type == .countryFilter})[items.count - 1].endDate {
                let currentDate = Date().timeIntervalSince1970
                let seconds = (fTime - currentDate)
                if seconds >= 0 {
                    countryTimer.resetTimer(seconds: seconds)
                    countryTimer.startTimer(seconds: TimeInterval(seconds))
                    countryTimer.delegate = self
                    vCountryPlaceholder.isHidden = true
                    countryTimerStackView.isHidden = false
                    btnFindBottle.isEnabled = true
                    btnFindBottle.alpha = 1.0
                }else{
                    vCountryPlaceholder.isHidden = false
                    countryTimerStackView.isHidden = true
                }
                
            } else {
                vCountryPlaceholder.isHidden = false
                countryTimerStackView.isHidden = true
            }
        }
    }
    
    @IBAction func allGenderBtnPressed(_ sender: Any) {
        allGenderButton.alpha = 1
        allGenderLabel.alpha = 1
        maleButton.alpha = 0.5
        maleLabel.alpha = 0.5
        femaleButton.alpha = 0.5
        femaleLabel.alpha = 0.5
        selectedGender = GenderType.allGender.rawValue
        self.delegate?.filterViewGet(self, gender: selectedGender, country: selectedCountry)
    }
    
    @IBAction func maleBtnPressed(_ sender: Any) {
        
        if DataStore.shared.inventoryItems.filter({$0.type == .genderFilter}).count == 0 {
            self.delegate?.filterViewGoToShop(self, productType: .genderFilter)
        } else {
            maleButton.alpha = 1
            maleLabel.alpha = 1
            femaleButton.alpha = 0.5
            femaleLabel.alpha = 0.5
            allGenderButton.alpha = 0.5
            allGenderLabel.alpha = 0.5
            selectedGender = GenderType.male.rawValue
            self.delegate?.filterViewGet(self, gender: selectedGender, country: selectedCountry)
        }
    }
    
    @IBAction func femalePressed(_ sender: Any) {
        
        if DataStore.shared.inventoryItems.filter({$0.type == .genderFilter}).count == 0 {
            self.delegate?.filterViewGoToShop(self, productType: .genderFilter)
        } else {
            femaleButton.alpha = 1
            femaleLabel.alpha = 1
            maleButton.alpha = 0.5
            maleLabel.alpha = 0.5
            allGenderButton.alpha = 0.5
            allGenderLabel.alpha = 0.5
            selectedGender = GenderType.female.rawValue
            self.delegate?.filterViewGet(self, gender: selectedGender, country: selectedCountry)
        }
    }
    
    func onFilterViewAppaer() {
        ApiManager.shared.requestUserInventoryItems { (items, error) in
            self.refreshFilterView()
        }
    }
    
    @IBAction func countryFilterBtnPressed(_ sender: AnyObject) {
        self.delegate?.filterViewGoToShop(self, productType: .countryFilter)
        Flurry.logEvent(AppConfig.filter_pressed_go_country);
    }
    
    @IBAction func genderFilterBtnPressed(_ sender: AnyObject) {
        self.delegate?.filterViewGoToShop(self, productType: .genderFilter)
        Flurry.logEvent(AppConfig.filter_pressed_go_gender);
    }
    
    @IBAction func findBottlePressed(_ sender: Any) {
        self.delegate?.filterViewFindBottle(self)
    }
    
    @IBAction func buyGenderFilterAction(_ sender: Any) {
        delegate?.filterViewGoToShop(self, productType: .genderFilter)
    }
    
    @IBAction func buyCountryFilterAction(_ sender: Any) {
        delegate?.filterViewGoToShop(self, productType: .countryFilter)
    }
    
    @IBAction func clearSlectedCountryAction(_ sender: Any) {
        self.selectedCountry = AppConfig.NO_COUNTRY_SELECTED
        self.countryPickerOverlay.isHidden = false
        self.delegate?.filterViewGet(self, gender: selectedGender, country: selectedCountry)
    }
    
    @IBAction func countryPickerOverlayAction(_ sender: Any) {
        if let viewController = delegate as? UIViewController {
            self.countryPicker.showCountriesList(from: viewController)
        }
    }
}

// MARK:- CountryPickerDelegate
extension FilterView: CountryPickerViewDelegate, CountryPickerViewDataSource {
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
        return false
    }
    
    
//    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
//
//    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        if DataStore.shared.inventoryItems.filter({$0.type == .countryFilter}).count == 0 {
            self.delegate?.filterViewGoToShop(self, productType: .countryFilter)
        } else {
            self.selectedCountry = country.code
            self.countryPickerOverlay.isHidden = true
            self.delegate?.filterViewGet(self, gender: selectedGender, country: selectedCountry)
        }
    }
    
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country]? {
        var countries = [Country]()
        ["SA", "AE", "SY", "LB", "IQ", "KW", "OM", "DZ", "BH", "EG", "JO", "LY", "PS", "QA", "SD"].forEach { code in
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


extension FilterView: TimerLabelDelegate {
    func timerFinished() {
        refreshFilterView()
    }
}
