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
    private let kTitle: String = "title"
    private let kText: String = "text"
    private let kCreatedAt: String = "createdAt"
    
    // MARK: Properties
    public var title: String?
    public var text: String?
    public var createdAt: String?
    
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

        return dictionary
    }
}
