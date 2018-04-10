//
//  FilterView.swift
//  Vobble
//
//  Created by Bayan on 3/11/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation


@objc protocol FilterViewDelegate {
    
    func getFilterInfo(gender: String, country: String)
    
}

class FilterView: AbstractNibView {
 
    @IBOutlet weak var allGenderButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var delegate: FilterViewDelegate?
    @IBOutlet weak var allGenderLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    fileprivate var selectedGender: String = "allGender"
    fileprivate var selectedCountry: String = "Afghanistan"
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        allGenderLabel.text = "ALL_GENDER".localized
        maleLabel.text = "MALE".localized
        femaleLabel.text = "FEMALE".localized
        allGenderButton.alpha = 1
        allGenderLabel.alpha = 1
        
    }
    
    @IBAction func allGenderBtnPressed(_ sender: Any) {
        allGenderButton.alpha = 1
        allGenderLabel.alpha = 1
        maleButton.alpha = 0.5
        maleLabel.alpha = 0.5
        femaleButton.alpha = 0.5
        femaleLabel.alpha = 0.5
        selectedGender = "allGender"
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
    }
    
    @IBAction func maleBtnPressed(_ sender: Any) {
        maleButton.alpha = 1
        maleLabel.alpha = 1
        femaleButton.alpha = 0.5
        femaleLabel.alpha = 0.5
        allGenderButton.alpha = 0.5
        allGenderLabel.alpha = 0.5
        selectedGender = "male"
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)

    }
    
    @IBAction func femalePressed(_ sender: Any) {
        femaleButton.alpha = 1
        femaleLabel.alpha = 1
        maleButton.alpha = 0.5
        maleLabel.alpha = 0.5
        allGenderButton.alpha = 0.5
        allGenderLabel.alpha = 0.5
        selectedGender = "female"
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
    }
    
    
}

// MARK:- CountryPickerDelegate
extension FilterView: CountryPickerDelegate {
    
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        self.selectedCountry = code
        self.delegate?.getFilterInfo(gender: selectedGender, country: selectedCountry)
        
    }
}
