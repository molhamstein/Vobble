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

    // MARK: Properties
    public var name:String?
    public var cover:String?
    public var icon:String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        if let value = json["name"].string {
            name = value
        }
        
        if let value = json["cover"].string {
            cover = value
        }
        
        if let value = json["icon"].string {
            icon = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        if let value = name {
            dictionary["name"] = value
        }
        if let value = cover {
            dictionary["cover"] = value
        }
        if let value = icon {
            dictionary["icon"] = value
        }
        return dictionary
    }
    
}
