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
    private let kUpdatedAt: String = "updatedAt"
    private let kStartTime: String = "startTime"
    private let kFinishTime: String = "finishTime"
    private let kIsSeen: String = "is_seen"
    private let kUser1UnseenMessagesCount: String = "user1_unseen"
    private let kUser2UnseenMessagesCount: String = "user2_unseen"
    private let kUser1LastSeenMessageId: String = "user1LastSeenMessageId"
    private let kUser2LastSeenMessageId: String = "user2LastSeenMessageId"
    private let kUser1ChatMute: String = "user1ChatMute"
    private let kUser2ChatMute: String = "user2ChatMute"
    
    // MARK: Properties
    public var idString : String?
    public var user : AppUser?
    public var bottle: Bottle?
    public var createdAt: Double?
    public var updatedAt: Double?
    public var startTime: Double?
    public var finishTime: Double?
    public var is_seen: Int?
    public var user1UnseenMessagesCount: Int?
    public var user2UnseenMessagesCount: Int?
    public var user1LastSeenMessageId: String?
    public var user2LastSeenMessageId: String?
    public var user1ChatMute: Bool?
    public var user2ChatMute: Bool?
    
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
    
    public var myUnseenMessagesCount: Int {
        get {
            if DataStore.shared.me?.objectId == user?.objectId {
              return user2UnseenMessagesCount ?? 0
            } else {
              return user1UnseenMessagesCount ?? 0
            }
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
        if let value = json[kUpdatedAt].double {
            updatedAt = value
        }
        if let value = json[kStartTime].double {
            startTime = value
        }
        if let value = json[kIsSeen].int {
            is_seen = value
        }
        if let value = json[kUser1UnseenMessagesCount].int {
            user1UnseenMessagesCount = value
        }
        if let value = json[kUser2UnseenMessagesCount].int {
            user2UnseenMessagesCount = value
        }
        
        if let value = json[kUser1LastSeenMessageId].string {
            user1LastSeenMessageId = value
        }
        
        if let value = json[kUser2LastSeenMessageId].string {
            user2LastSeenMessageId = value
        }
        
        if let value = json[kUser1ChatMute].bool {
            user1ChatMute = value
        }
        
        if let value = json[kUser2ChatMute].bool {
            user2ChatMute = value
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
        
        if let value = updatedAt {
            dictionary[kUpdatedAt] = value
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
        
        if let value = user1UnseenMessagesCount {
            dictionary[kUser1UnseenMessagesCount] = value
        }
        
        if let value = user2UnseenMessagesCount {
            dictionary[kUser2UnseenMessagesCount] = value
        }
        
        if let value = user1LastSeenMessageId {
            dictionary[kUser1LastSeenMessageId] = value
        }
        
        if let value = user2LastSeenMessageId {
            dictionary[kUser2LastSeenMessageId] = value
        }
        
        if let value = user1ChatMute {
            dictionary[kUser1ChatMute] = value
        }
        
        if let value = user2ChatMute {
            dictionary[kUser2ChatMute] = value
        }
        
        return dictionary
    }

    
}
