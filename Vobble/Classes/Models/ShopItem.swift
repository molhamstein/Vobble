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
    
    case bottlesPack = "5b13ee987fe59d9d184bfe3e"
    case genderFilter = "5b13ee987fe59d9d184bfe3f"
    case countryFilter = "5b13ee987fe59d9d184bfe40"
    case ExtendChat = "5cd2d56bf133b83d7c653d8f"
    case coinsPack = "5d909c02b2cf5c43578ea28d"
    case replies = "5d909c02b2cf5c43578ea28e"
    
}

enum ShopItemID: String {
    
    case Bottels3 = "com.yallavideo.Vibo.bottels3"
    case Bottels5 = "com.yallavideo.Vibo.5bottels"
    case Bottels10 = "com.yallavideo.Vibo.bottels10"
    
    case CountryFilter1H = "com.yallavideo.Vibo.1hcountry"
    case CountryFilter12H = "com.yallavideo.Vibo.country12h"
    case CountryFilter24H = "com.yallavideo.Vibo.24hcountry"
    case CountryFilter48H = "com.yallavideo.Vibo.48hcountry"
    
    case GenderFilter1H = "com.yallavideo.Vibo.1hgender"
    case GenderFilter12H = "com.yallavideo.Vibo.gender12h"
    case GenderFilter24H = "com.yallavideo.Vibo.24hgender"
    case GenderFilter48H = "com.yallavideo.Vibo.48hgender"
    
    case ExtendChat1 = "com.yallavideo.Vibo.1extend"
    case ExtendChat3 = "com.yallavideo.Vibo.3extend"
    case ExtendChat6 = "com.yallavideo.Vibo.6extend"
    
    case Coins500 = "com.yallavideo.Vibo.coins500"
    case Coins1200 = "com.yallavideo.Vibo.coins1200"
    case Coins2500 = "com.yallavideo.Vibo.coins2500"
    case Coins6500 = "com.yallavideo.Vibo.coins6500"
    case Coins14000 = "com.yallavideo.Vibo.coins14000"
    
    static func getIdFromKey(DBId: String) -> String {
        
        switch DBId {
        case "5b13ee987fe59d9d184bfe44":
            return Bottels3.rawValue
            
        case "5b13ee987fe59d9d184bfe45":
            return Bottels5.rawValue
            
        case "5b13ee987fe59d9d184bfe48":
            return CountryFilter24H.rawValue
            
        case "5b13ee987fe59d9d184bfe49":
            return CountryFilter48H.rawValue
            
        case "5b13ee987fe59d9d184bfe46":
            return GenderFilter24H.rawValue
            
        case "5b13ee987fe59d9d184bfe47":
            return GenderFilter48H.rawValue
            
        default:
            return ""
        }
    }
    
    static func getListId() -> [String] {
        
        var listId = [String]()
        
        listId.append(ShopItemID.Bottels3.rawValue)
        listId.append(ShopItemID.Bottels5.rawValue)
        listId.append(ShopItemID.Bottels10.rawValue)
        
        listId.append(ShopItemID.CountryFilter1H.rawValue)
        listId.append(ShopItemID.CountryFilter12H.rawValue)
        listId.append(ShopItemID.CountryFilter24H.rawValue)
        listId.append(ShopItemID.CountryFilter48H.rawValue)
        
        listId.append(ShopItemID.GenderFilter1H.rawValue)
        listId.append(ShopItemID.GenderFilter12H.rawValue)
        listId.append(ShopItemID.GenderFilter24H.rawValue)
        listId.append(ShopItemID.GenderFilter48H.rawValue)
        
        listId.append(ShopItemID.ExtendChat1.rawValue)
        listId.append(ShopItemID.ExtendChat3.rawValue)
        listId.append(ShopItemID.ExtendChat6.rawValue)
        
        listId.append(ShopItemID.Coins500.rawValue)
        listId.append(ShopItemID.Coins1200.rawValue)
        listId.append(ShopItemID.Coins2500.rawValue)
        listId.append(ShopItemID.Coins6500.rawValue)
        listId.append(ShopItemID.Coins14000.rawValue)
        
        return listId
    }
}

class ShopItem: BaseModel {
    
    // MARK: Keys
    private let kShopItemId: String = "id"
    private let kShopItemTitle_en: String = "name_en"
    private let kShopItemTitle_ar: String = "name_ar"
    private let kShopItemDescription_en: String = "description_en"
    private let kShopItemDescription_ar: String = "description_ar"
    private let kShopItemPrice: String = "price"
    private let kShopItemPriceCoins: String = "price_coins"
    private let kShopItemFirstColor: String = "fcolor"
    private let kShopItemSecondColor: String = "lcolor"
    private let kShopItemImageUrl: String = "icon"
    private let kShopItemValidity: String = "validity"
    private let kShopItemBottlesCount: String = "bottleCount"
    
    private let kShopItemType: String = "typeGoodsId"
    private let kShopItemProdId: String = "ProdId"
    private let kShopItemStartDate: String = "startDate"
    private let kShopItemEndDate: String = "EndDate"
    
    private let kShopItemAppleProduct: String = "appleProduct"
    
    
    
    // MARK: Properties
    public var idString : String?
    public var title_ar : String?
    public var title_en : String?
    public var description_ar : String?
    public var description_en : String?
    public var price : Double?
    public var priceCoins : Int?
    //public var firstColor : UIColor?
    //public var secondColor : UIColor?
    public var icon : String?
    
    public var prodId : String?
    public var startDate : Double?
    public var endDate : Double?
    public var validity : Double?
    public var bottlesCount : Double?
    public var type : ShopItemType?
    
    public var appleProduct : String?
    
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
                case .ExtendChat:
                    return AppColors.blueXLight
                case .coinsPack:
                    return AppColors.grayLight
                case .replies:
                    return AppColors.blueXLight
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
                case .ExtendChat:
                    return AppColors.blueXDark
                case .coinsPack:
                    return AppColors.grayDark
                case .replies:
                    return AppColors.blueXDark
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
        if let value = json[kShopItemPrice].double {
            price = value
        }
        if let value = json[kShopItemValidity].double {
            validity = value
        }
        if let value = json[kShopItemBottlesCount].double {
            bottlesCount = value
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
        if let value = json[kShopItemPriceCoins].int {
            priceCoins = value
        }
        
        // trating the goods id as an enum to define product type
        if let value = json[kShopItemType].string {
            type = ShopItemType(rawValue: value)
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
        
        if let value = json[kShopItemAppleProduct].string {
            appleProduct = value
        }
        
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
        
        if let value = validity {
            dictionary[kShopItemValidity] = value
        }
        
        if let value = bottlesCount {
            dictionary[kShopItemBottlesCount] = value
        }
        
        if let value = icon {
            dictionary[kShopItemImageUrl] = value
        }
        
        if let value = priceCoins {
            dictionary[kShopItemPriceCoins] = value
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
        
        if let value = appleProduct {
            dictionary[kShopItemAppleProduct] = value
        }
        
        return dictionary
    }

}
