//
//  ShopItem.swift
//  Vobble
//
//  Created by Bayan on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON


enum ShopItemType: String {
    
    case bottlesPack = "5afc7b8683106e7603326ef0"
    case genderFilter = "5afc7b8683106e7603326ef1"
    case countryFilter = "5afc7b8683106e7603326ef2"
}

class ShopItem: BaseModel {
    
    
    // MARK: Keys
    private let kShopItemId: String = "id"
    private let kShopItemTitle_en: String = "name_en"
    private let kShopItemTitle_ar: String = "name_ar"
    private let kShopItemDescription_en: String = "description"
    private let kShopItemDescription_ar: String = "description"
    private let kShopItemPrice: String = "price"
    private let kShopItemFirstColor: String = "fcolor"
    private let kShopItemSecondColor: String = "lcolor"
    private let kShopItemImageUrl: String = "icon"
    
    private let kShopItemType: String = "typeGoodsId"
    private let kShopItemProdId: String = "ProdId"
    private let kShopItemStartDate: String = "startDate"
    private let kShopItemEndDate: String = "EndDate"
    
    
    // MARK: Properties
    public var idString : String?
    public var title_ar : String?
    public var title_en : String?
    public var description_ar : String?
    public var description_en : String?
    public var price : String?
    //public var firstColor : UIColor?
    //public var secondColor : UIColor?
    public var icon : String?
    
    public var prodId : String?
    public var startDate : Double?
    public var endDate : Double?
    public var type : ShopItemType?
    
    public var title: String? {
        get {
            return AppConfig.currentLanguage == .arabic ? title_ar : title_en
        }
    }
    
    public var description: String? {
        get {
            return AppConfig.currentLanguage == .arabic ? description_ar : description_en
        }
    }
    
    public var firstColor: UIColor {
        get {
            if let itemType = type {
                switch itemType {
                case .bottlesPack:
                    return AppColors.blueXLight
                case .genderFilter:
                    return AppColors.pinkLight
                case .countryFilter:
                    return AppColors.grayXLight
                }
            }
            return AppColors.blueXLight
        }
    }
    
    public var secondColor: UIColor {
        get {
            if let itemType = type {
                switch itemType {
                case .bottlesPack:
                    return AppColors.blueXDark
                case .genderFilter:
                    return AppColors.pinkDark
                case .countryFilter:
                    return AppColors.grayXDark
                }
            }
            return AppColors.blueXDark
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
      
        if let value = json[kShopItemId].string {
            idString = value
        }
        if let value = json[kShopItemTitle_en].string {
            title_en = value
        }
        if let value = json[kShopItemTitle_ar].string {
            title_ar = value
        }
        if let value = json[kShopItemDescription_en].string {
            description_en = value
        }
        if let value = json[kShopItemDescription_ar].string {
            description_ar = value
        }
        if let value = json[kShopItemPrice].string {
            price = value
        }
        if let value = json[kShopItemImageUrl].string {
            icon = value
        }
        if let value = json[kShopItemType].string {
            type = ShopItemType(rawValue: value)
        }
        if let value = json[kShopItemEndDate].double {
            endDate = value
        }
        if let value = json[kShopItemStartDate].double {
            startDate = value
        }
        if let value = json[kShopItemProdId].string {
            prodId = value
        }
        
//        if let value = json[kShopItemFirstColor].string {
//            firstColor = value
//        }
//        if let value = json[kShopItemSecondColor].string {
//            secondColors = value
//        }
        //set image
//        if let value = json[kShopItemImageUrl].string {
//            imageUrl = value
//        }
        
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = idString {
            dictionary[kShopItemId] = value
        }
        
        if let value = title_en {
            dictionary[kShopItemTitle_en] = value
        }
        if let value = title_ar {
            dictionary[kShopItemTitle_ar] = value
        }
        
        if let value = description_en {
            dictionary[kShopItemDescription_en] = value
        }
        if let value = description_ar {
            dictionary[kShopItemDescription_ar] = value
        }
        
        if let value = price {
            dictionary[kShopItemPrice] = value
        }
        
        if let value = icon {
            dictionary[kShopItemImageUrl] = value
        }
        
//        if let value = firstColor {
//            dictionary[kShopItemFirstColor] = value
//        }
//        
//        if let value = secondColor {
//            dictionary[kShopItemSecondColor] = value
//        }
        
        if let value = type {
            dictionary[kShopItemType] = value.rawValue
        }
        
        if let value = endDate {
            dictionary[kShopItemEndDate] = value
        }
        
        if let value = startDate {
            dictionary[kShopItemStartDate] = value
        }
        
        if let value = prodId {
            dictionary[kShopItemProdId] = value
        }
        
//        if let value = imageUrl {
//            dictionary[kShopItemImageUrl] = value
//        }
        
        return dictionary
    }

}
