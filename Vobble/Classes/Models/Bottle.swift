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
    private let kStatus: String = "status"
    private let kViewsCount: String = "viewsCount"
    private let kRepliesCount: String = "repliesCount"
    private let kCreatedAt: String = "createdAt"
    private let kOwnerId: String = "ownerId"
    private let kShoreId: String = "shoreId"
    
    
    // MARK: Properties
    public var idString : String?
    public var status : String?
    public var viewsCount : String?
    public var repliesCount : String?
    public var createdAt : UIColor?
    public var ownerId : AppUser?
    public var shoreId : UIImage?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kBottleId].string {
            idString = value
        }
        if let value = json[kStatus].string {
            status = value
        }
        if let value = json[kViewsCount].string {
            viewsCount = value
        }
        if let value = json[kRepliesCount].string {
            repliesCount = value
        }
//                if let value = json[kCreatedAt].string {
//                    createdAt = value
//                }
//                if let value = json[kOwnerId].string {
//                    ownerId = value
//                }
//        set image
//                if let value = json[kShoreId].string {
//                    shoreId = value
//                }
        
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = idString {
            dictionary[kBottleId] = value
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
        
        if let value = ownerId {
            dictionary[kCreatedAt] = value
        }
        
        if let value = ownerId {
            dictionary[kOwnerId] = value
        }
        
        //        if let value = shoreId {
        //            dictionary[kShoreId] = value
        //        }
        
        return dictionary
    }
    
}
