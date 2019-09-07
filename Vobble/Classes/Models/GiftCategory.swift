//
//  GiftCategory.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class GiftCategory: BaseModel {
    
    // MARK: Keys
    private let kId: String = "id"
    private let kname_en: String = "name_en"
    private let kname_ar: String = "name_ar"
    private let kChatProducts: String = "chatProduct"
    
    // MARK: Properties
    public var categoryId: String?
    public var name_ar: String?
    public var name_en: String?
    public var chatProducts: [ChatProduct]?
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
            categoryId = value
        }
        if let value = json[kname_ar].string {
            name_ar = value
        }
        
        if let value = json[kname_en].string {
            name_en = value
        }
        
        if let value = json[kChatProducts].array {
            chatProducts = value.map{ChatProduct(json:$0)}
        }
        
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = categoryId {
            dictionary[kId] = value
        }
        if let value = name_ar {
            dictionary[kname_ar] = value
        }
        if let value = name_en {
            dictionary[kname_en] = value
        }
        if let array: [ChatProduct] = chatProducts {
            let chatProductsDictionaries : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
            dictionary[kChatProducts] = chatProductsDictionaries
        }
        return dictionary
    }
    
}
