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
    private let kuser1: String = "user1"
    private let kuser2: String = "user2"
    private let kBottle: String = "bottle"
    private let kTimeleft: String = "timeleft"
    
    
    // MARK: Properties
    public var idString : String?
    public var user1 : AppUser?
    public var user2 : AppUser?
    public var bottle: Bottle?
    public var timeLeft: String?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kConvId].string {
            idString = value
        }
//        if let value = json[kuser1].string {
//            user1 = value
//        }
//        if let value = json[kuser2].string {
//            user2 = value
//        }
//        if let value = json[kBottle].string {
//            bottle = value
//        }
        
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = idString {
            dictionary[kConvId] = value
        }
        
//        if let value = user1 {
//            dictionary[kuser1] = value
//        }
//        
//        if let value = user2 {
//            dictionary[kuser2] = value
//        }
        
//        if let bottle = time {
//            dictionary[kBottle] = value
//        }
        
        return dictionary
    }

    
}
