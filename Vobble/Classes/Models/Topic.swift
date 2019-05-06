//
//  Topic.swift
//  Vobble
//
//  Created by Abd Hayek on 3/4/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Topic : BaseModel {
    // MARK: Keys
    private let kTopicId: String = "id"
    private let kText_en: String = "text_en"
    private let kText_ar: String = "text_ar"
    private let kStatus: String = "status"
    private let kCreatedAt: String = "createdAt"
    
    // MARK: Properties
    public var topicId:String?
    public var textEn:String?
    public var textAr:String?
    public var status:String?
    public var createdAt: String?
    
    public var text: String? {
        get {
            return AppConfig.currentLanguage == .arabic ? textAr : textEn
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kTopicId].string {
            topicId = value
        }
        if let value = json[kText_ar].string {
            textAr = value
        }
        
        if let value = json[kText_en].string {
            textEn = value
        }
        
        if let value = json[kStatus].string {
            status = value
        }
        
        if let value = json[kCreatedAt].string {
            createdAt = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = topicId {
            dictionary[kTopicId] = value
        }
        
        if let value = textAr {
            dictionary[kText_ar] = value
        }
        
        if let value = textEn {
            dictionary[kText_en] = value
        }
        
        if let value = status {
            dictionary[kStatus] = value
        }
        
        if let value = createdAt {
            dictionary[kCreatedAt] = value
        }
        return dictionary
    }
    
}
