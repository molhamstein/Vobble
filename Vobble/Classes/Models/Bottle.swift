//
//  Bottle.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Bottle: BaseModel {
    
    // MARK: Keys
    private let kBottleId: String = "id"
    private let kFile: String = "file"
    private let kStatus: String = "status"
    private let kViewsCount: String = "viewsCount"
    private let kRepliesCount: String = "repliesCount"
    private let kRepliesUserCount: String = "repliesUserCount"
    private let kOwnerId: String = "ownerId"
    private let kOwner: String = "owner"
    private let kShoreId: String = "shoreId"
    private let kattachment: String = "file"
    private let kThumb: String = "thumbnail"
    private let kShore: String = "shore"
    
    
    // MARK: Properties
    public var bottle_id : String?
    public var file : String?
    public var status : String?
    public var viewsCount : Int?
    public var repliesCount : Int?
    public var repliesUserCount : Int?
    public var ownerId : String?
    public var shoreId : String?
    public var attachment: String?
    public var thumb: String?
    public var owner: AppUser?
    public var shore: Shore?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kBottleId].string {
            bottle_id = value
        }
        if let value = json[kFile].string {
            file = value
        }
        if let value = json[kRepliesUserCount].int {
            repliesUserCount = value
        }
        if let value = json[kStatus].string {
            status = value
        }
        if let value = json[kViewsCount].int {
            viewsCount = value
        }
        if let value = json[kRepliesCount].int {
            repliesCount = value
        }
        if let value = json[kattachment].string {
            attachment = value
        }
        if let value = json[kThumb].string {
            thumb = value
        }
        if let value = json[kOwnerId].string {
            ownerId = value
        }
        if let value = json[kShoreId].string {
                shoreId = value
        }
        if json[kOwner] != JSON.null {
            owner = AppUser(json: json[kOwner])
        }
        if json[kShore] != JSON.null {
            shore = Shore(json: json[kShore])
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = bottle_id {
            dictionary[kBottleId] = value
        }
        
        if let value = file {
            dictionary[kFile] = value
        }
        
        if let value = status {
            dictionary[kStatus] = value
        }
        
        if let value = viewsCount {
            dictionary[kViewsCount] = value
        }
        
        if let value = repliesCount {
            dictionary[kRepliesCount] = value
        }
        
        if let value = repliesUserCount {
            dictionary[kRepliesUserCount] = value
        }
        
        if let value = ownerId {
            dictionary[kOwnerId] = value
        }
        
        if let value = attachment {
            dictionary[kattachment] = value
        }
        
        if let value = thumb {
            dictionary[kThumb] = value
        }
        
        if let value = shoreId {
            dictionary[kShoreId] = value
        }
        
        if let value = owner {
            dictionary[kOwner] = value.dictionaryRepresentation()
        }
        
        if let value = shore {
            dictionary[kShore] = value.dictionaryRepresentation()
        }
        
        return dictionary
    }
    
}
