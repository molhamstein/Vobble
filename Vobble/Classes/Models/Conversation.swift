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
    private let kStartTime: String = "startTime"
    private let kFinishTime: String = "finishTime"
    private let kIsSeen: String = "is_seen"
    
    
    // MARK: Properties
    public var idString : String?
    public var user : AppUser?
    public var bottle: Bottle?
    public var createdAt: Double?
    public var startTime: Double?
    public var finishTime: Double?
    public var is_seen: Int?
    
    public var isExpired:Bool {
        get {
            let currentDate = Date().timeIntervalSince1970 * 1000
            if let ft = finishTime {
                if  currentDate >= ft {
                    return true
                } else {
                    return false
                }
            }
            return false
        }
    }
    
    public var getPeer: AppUser? {
        get {
            return user?.objectId == DataStore.shared.me?.objectId ? bottle?.owner : user
        }
    }
    
    public var isMyBottle: Bool {
        get {
            if let currentUserID = DataStore.shared.me?.objectId, let convUserID = self.bottle?.ownerId, currentUserID == convUserID {
                return true
            }
            return false
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
        if let value = json[kStartTime].double {
            startTime = value
        }
        if let value = json[kIsSeen].int {
            is_seen = value
        }
        
        if let sTime = startTime, sTime > 0.0 {
            finishTime = sTime + AppConfig.chatValidityafterSeen
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
        
        if let value = startTime {
            dictionary[kStartTime] = value
        }
        
        if let value = finishTime {
            dictionary[kFinishTime] = value
        }
        
        if let value = is_seen {
            dictionary[kIsSeen] = value
        }
        
        return dictionary
    }

    
}
