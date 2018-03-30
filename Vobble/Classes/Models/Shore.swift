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
    private let kname: String = "name"
    private let kcover: String = "cover"
    private let kicon: String = "icon"
    
    // MARK: Properties
    public var shore_id:Int?
    public var name:String?
    public var cover:String?
    public var icon:String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kshoreId].int {
            shore_id = value
        }
        if let value = json[kname].string {
            name = value
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
        if let value = name {
            dictionary[kname] = value
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
