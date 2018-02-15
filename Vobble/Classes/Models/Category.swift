//
//  Category.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/27/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

class Category: BaseModel {
    // MARK: Keys
    private let kCategoryName: String = "name"
    // MARK: Properties
    public var name:String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        if let value = json[kCategoryName].string {
            name = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        if let value = name {
            dictionary[kCategoryName] = value
        }
        return dictionary
    }
}
