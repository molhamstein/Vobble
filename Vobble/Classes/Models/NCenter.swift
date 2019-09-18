//
//  Notification.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/16/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class NCenter: BaseModel {
    
    // MARK: Keys
    private let kNId: String = "id"
    private let kTitle: String = "title"
    private let kText: String = "text"
    private let kCreatedAt: String = "createdAt"
    private let kIsSeen: String = "isSeen"
    private let kImage: String = "image"
    
    // MARK: Properties
    public var notificationId: String?
    public var title: String?
    public var text: String?
    public var createdAt: String?
    public var isSeen: Bool?
    public var image: String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kTitle].string {
            title = value
        }
        if let value = json[kText].string {
            text = value
        }
        if let value = json[kCreatedAt].string {
            createdAt = value
        }
        if let value = json[kIsSeen].bool {
            isSeen = value
        }
        if let value = json[kImage].string {
            image = value
        }
        if let value = json[kNId].string {
            notificationId = value
        }
        
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = title {
            dictionary[kTitle] = value
        }
        if let value = text {
            dictionary[kText] = value
        }
        if let value = createdAt {
            dictionary[kCreatedAt] = value
        }
        if let value = isSeen {
            dictionary[kIsSeen] = value
        }
        if let value = image {
            dictionary[kImage] = value
        }
        if let value = notificationId {
            dictionary[kNId] = value
        }

        return dictionary
    }
}
