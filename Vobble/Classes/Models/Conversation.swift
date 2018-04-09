//
//  Conversation.swift
//  Vobble
//
//  Created by Bayan on 3/14/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Conversation: BaseModel {
    
    // MARK: Keys
    private let kConvId: String = "id"
    private let kuser: String = "user"
    private let kBottle: String = "bottle"
    private let kCreatedAt: String = "createdAt"
    
    
    // MARK: Properties
    public var idString : String?
    public var user : AppUser?
    public var bottle: Bottle?
    public var createdAt: Double?
    public var finishTime: Double?
    private var _isActive: Bool?
    
    
    public var isActive:Bool? {
        set{
            _isActive = newValue
        }
        get {
            let currentDate = Date().timeIntervalSince1970 * 1000
            if let ft = finishTime {
                if  currentDate >= ft {
                    _isActive = true
                } else {
                    _isActive = false
                }
            }
            return _isActive
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kConvId].string {
            idString = value
        }
        if json[kuser] != JSON.null {
            user = AppUser(json: json[kuser])
        }
        if json[kBottle] != JSON.null {
            bottle = Bottle(json: json[kBottle])
        }
        if let value = json[kCreatedAt].double {
            createdAt = value
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = idString {
            dictionary[kConvId] = value
        }
        
        if let value = user {
            dictionary[kuser] = value.dictionaryRepresentation()
        }
        
        if let value = bottle {
            dictionary[kBottle] = value.dictionaryRepresentation()
        }
        
        if let value = createdAt {
            dictionary[kCreatedAt] = value
        }
        
        return dictionary
    }

    
}
