//
//  Media.swift
//  Vobble
//
//  Created by Bayan on 3/27/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Media: BaseModel {
    
    // MARK: Keys
    private let kname: String = "name"
    private let ktype: String = "type"
    
    // MARK: Properties
    public var name : String?
    public var type : String?
    public var fileUrl: String?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kname].string {
            name = value
        }
        if let value = json[ktype].string {
            type = value
        }
        if let n = name {
           self.fileUrl = "\(AppConfig.appBaseDevURL)/uploads/videos/download/\(n)" 
        }
        
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = name {
            dictionary[kname] = value
        }
        if let value = type {
            dictionary[ktype] = value
        }
        
        return dictionary
    }
    
}
