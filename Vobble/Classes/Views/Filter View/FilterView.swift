//
//  FilterView.swift
//  Vobble
//
//  Created by Bayan on 3/11/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

@objc enum filterType:Int {
    case genderFilter
    case countryFilter
    case bottlesFilter
}

@objc protocol FilterViewDelegate {
    
    func getFilterInfo(gender: String, country: String)
    func showBuyFilterMessage(type:filterType)
    
}

class FilterView: AbstractNibView {
 
    @IBOutlet weak var allGenderButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var delegate: FilterViewDelegate?
    @IBOutlet weak var allGenderLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var genderFilterStackView: UIStackView!
    @IBOutlet weak var genderTimerStackView: UIStackView!
    @IBOutlet weak var genderTimer: TimerLabel!
    @IBOutlet weak var countryTimerStackView: UIStackView!
    @IBOutlet weak var countryFilterStackView: UIStackView!
    @IBOutlet weak var countryTimer: TimerLabel!
    @IBOutlet weak var countryLeftLabel: UILabel!
    @IBOutlet weak var genderLeftLabel: UILabel!
    @IBOutlet weak var genderBuyFilterButton: UIButton!
    @IBOutlet weak var countryBuyFilterButton: UIButton!
    
    fileprivate var selectedGender: String = GenderType.allGender.rawValue
    fileprivate var selectedCountry: String = "Afghanistan"
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        allGenderLabel.text = "ALL_GENDER".localized
        maleLabel.text = "MALE".localized
        femaleLabel.text = "FEMALE".localized
        allGenderButton.alpha = 1
        allGenderLabel.alpha = 1
        genderTimerStackView.isHidden = true
        countryTimerStackView.isHidden = true
        
        if DataStore.shared.shopItems.filter({$0.type == "genderFilter"}).count > 0 {
            genderTimerStackView.isHidden = false
            genderFilterStackView.isHidden = true
            
            if let fTime = DataStore.shared.shopItems.filter({$0.type == "genderFilter"})[0].endDate {
                let currentDate = Date().timeIntervalSince1970 * 1000
                let seconds = (fTime - currentDate)/1000.0
                genderTimer.startTimer(seconds: TimeInterval(seconds))
            }
            
        }
        if DataStore.shared.shopItems.filter({$0.type == "countryFilter"}).count > 0 {
            countryTimerStackView.isHidden = false
            countryFilterStackView.isHidden = true
            
            if let fTime = DataStore.shared.shopItems.filter({$0.type == "countryFilter"})[0].endDate {
                let currentDate = Date().timeIntervalSince1970 * 1000
                let seconds = (fTime - currentDate)/1000.0
                countryTimer.startTimer(seconds: TimeInterval(seconds))
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
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
    }
    
    @IBAction func maleBtnPressed(_ sender: Any) {
        
        if DataStore.shared.shopItems.filter({$0.type == "genderFilter"}).count > 0 {
            self.delegate?.showBuyFilterMessage(type: .genderFilter)
        } else {
            maleButton.alpha = 1
            maleLabel.alpha = 1
            femaleButton.alpha = 0.5
            femaleLabel.alpha = 0.5
            allGenderButton.alpha = 0.5
            allGenderLabel.alpha = 0.5
            selectedGender = GenderType.male.rawValue
            self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
        }

    }
    
    @IBAction func femalePressed(_ sender: Any) {
        
        if DataStore.shared.shopItems.filter({$0.type == "genderFilter"}).count > 0 {
            self.delegate?.showBuyFilterMessage(type: .genderFilter)
        } else {
        femaleButton.alpha = 1
        femaleLabel.alpha = 1
        maleButton.alpha = 0.5
        maleLabel.alpha = 0.5
        allGenderButton.alpha = 0.5
        allGenderLabel.alpha = 0.5
        selectedGender = GenderType.female.rawValue
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
        }
    }
    
    @IBAction func countryFilterBtnPressed(_ sender: AnyObject) {
        self.delegate?.showBuyFilterMessage(type: .countryFilter)
    }
    
    @IBAction func genderFilterBtnPressed(_ sender: AnyObject) {
        self.delegate?.showBuyFilterMessage(type: .genderFilter)
    }
}

// MARK:- CountryPickerDelegate
extension FilterView: CountryPickerDelegate {
    
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        if DataStore.shared.shopItems.filter({$0.type == "countryFilter"}).count > 0 {
             self.delegate?.showBuyFilterMessage(type: .countryFilter)
        } else {
            self.selectedCountry = code
            self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
        }
    }
}
