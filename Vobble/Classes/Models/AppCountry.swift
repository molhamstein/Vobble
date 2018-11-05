//
//  Shore.swift
//  Vobble
//
//  Created by Molham mahmoud on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppCountry: BaseModel {

    // MARK: Keys
    private let kId: String = "code"
    private let kname_en: String = "name"
    
    // MARK: Properties
    public var objetcId:String?
    public var nameEn:String?
    
    public var name: String? {
        get {
            return nameEn
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kId].string {
            objetcId = value
        }
        if let value = json[kname_en].string {
            nameEn = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
       
        if let value = objetcId {
            dictionary[kId] = value
        }
        if let value = nameEn {
            dictionary[kname_en] = value
        }
        return dictionary
    }
    
}
