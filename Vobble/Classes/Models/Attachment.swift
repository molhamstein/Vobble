//
//  Attachment.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/10/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

enum AttachmentType:String{
    case image = "image"
    case video = "video"
}

class Attachment: BaseModel {
    
    // MARK: Keys
    private let kType: String = "type"
    private let kUrl: String = "url"
    private let kThunmbnail: String = "thumbnail"
    // MARK: Properties
    private var typeRawValue:String?
    public var thumbnail:String?
    public var url:String?
    // media type default is image
    public var type:AttachmentType {
        if let rawValue = typeRawValue {
            return AttachmentType(rawValue: rawValue) ?? .image
        }
        return .image
    }
    
    // MARK: Initializers
    public override init() {
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        if let value = json[kType].string{
            typeRawValue = value
        }
        if let value = json[kUrl].string{
            url = value
        }
        if let value = json[kThunmbnail].string{
            thumbnail = value
        }
    }
    
    public override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        // type raw value
        if let value = typeRawValue {
            dictionary[kType] = value
        }
        // url
        if let value = url {
            dictionary[kUrl] = value
        }
        // thumbnail
        if let value = thumbnail {
            dictionary[kThunmbnail] = value
        }
        return dictionary
    }
}
