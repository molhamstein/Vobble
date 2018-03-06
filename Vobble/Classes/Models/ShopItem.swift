//
//  ShopItem.swift
//  Vobble
//
//  Created by Bayan on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class ShopItem: BaseModel {
    
    // MARK: Keys
    private let kShopItemId: String = "id"
    private let kShopItemTitle: String = "title"
    private let kShopItemDescription: String = "description"
    private let kShopItemPrice: String = "price"
    private let kShopItemFirstColor: String = "fcolor"
    private let kShopItemSecondColor: String = "lcolor"
    private let kShopItemImageUrl: String = "imgurl"
    
    
    // MARK: Properties
    public var idString : String?
    public var title : String?
    public var description : String?
    public var price : String?
    public var firstColor : UIColor?
    public var secondColor : UIColor?
    public var imageUrl : UIImage?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
      
        if let value = json[kShopItemId].string {
            idString = value
        }
        if let value = json[kShopItemTitle].string {
            title = value
        }
        if let value = json[kShopItemDescription].string {
            description = value
        }
        if let value = json[kShopItemPrice].string {
            price = value
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
        
        if let value = title {
            dictionary[kShopItemTitle] = value
        }
        
        if let value = description {
            dictionary[kShopItemDescription] = value
        }
        
        if let value = price {
            dictionary[kShopItemPrice] = value
        }
        
        if let value = firstColor {
            dictionary[kShopItemFirstColor] = value
        }
        
        if let value = secondColor {
            dictionary[kShopItemSecondColor] = value
        }
        
//        if let value = imageUrl {
//            dictionary[kShopItemImageUrl] = value
//        }
        
        return dictionary
    }

}
