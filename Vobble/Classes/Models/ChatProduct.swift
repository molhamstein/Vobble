//
//  Gift.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatProduct: BaseModel {
    
    // MARK: Keys
    private let kId: String = "id"
    private let kname_en: String = "name_en"
    private let kname_ar: String = "name_ar"
    private let kPrice: String = "price"
    private let kIcon: String = "icon"

    // MARK: Properties
    public var productId:String?
    public var icon:String?
    public var price:Int?
    public var name_ar:String?
    public var name_en:String?
    public var name: String? {
        get {
            return AppConfig.currentLanguage == .arabic ? name_ar : name_en
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kId].string {
            productId = value
        }
        if let value = json[kPrice].int {
            price = value
        }
        if let value = json[kIcon].string {
            icon = value.replacingOccurrences(of: "\\", with: "")
        }
        if let value = json[kname_ar].string {
            name_ar = value
        }
        if let value = json[kname_en].string {
            name_en = value
        }
        
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = name_ar {
            dictionary[kname_ar] = value
        }
        if let value = name_en {
            dictionary[kname_en] = value
        }
        if let value = price {
            dictionary[kPrice] = value
        }
        if let value = icon {
            dictionary[kIcon] = value
        }
        if let value = productId {
            dictionary[kId] = value
        }
        
        return dictionary
    }
    
}
