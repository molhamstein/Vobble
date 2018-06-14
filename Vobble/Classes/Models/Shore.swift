//
//  Shore.swift
//  Vobble
//
//  Created by Molham mahmoud on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Shore: BaseModel {

    // MARK: Keys
    private let kshoreId: String = "id"
    private let kname_en: String = "name_en"
    private let kname_ar: String = "name_ar"
    private let kcover: String = "cover"
    private let kicon: String = "icon"
    
    // MARK: Properties
    public var shore_id:String?
    public var name_ar:String?
    public var name_en:String?
    public var cover:String?
    public var icon:String?
    
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
        
        if let value = json[kshoreId].string {
            shore_id = value
        }
        if let value = json[kname_ar].string {
            name_ar = value
        }
        
        if let value = json[kname_en].string {
            name_en = value
        }
        
        if let value = json[kcover].string {
            cover = value
        }
        
        if let value = json[kicon].string {
            icon = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
       
        if let value = shore_id {
            dictionary[kshoreId] = value
        }
        if let value = name_ar {
            dictionary[kname_ar] = value
        }
        if let value = name_en {
            dictionary[kname_en] = value
        }
        if let value = cover {
            dictionary[kcover] = value
        }
        if let value = icon {
            dictionary[kicon] = value
        }
        return dictionary
    }
    
}
