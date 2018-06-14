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
    private let kType: String = "type"
    private let kThumb: String = "thumbnail"
    private let kFile: String = "file"
    
    // MARK: Properties
    //public var name : String?
    public var type : AppMediaType?
    public var fileUrl: String?
    public var thumbUrl: String?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let n = json[kFile].string {
           self.fileUrl = n
        }
        if let t = json[kThumb].string {
            self.thumbUrl = t
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = fileUrl {
            dictionary[kFile] = value
        }
        if let value = thumbUrl {
            dictionary[kThumb] = value
        }
        if let value = type {
            dictionary[kType] = value.rawValue
        }
        
        return dictionary
    }
    
}
