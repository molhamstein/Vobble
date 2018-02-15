//
//  HashTag.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/10/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

class HashTag: BaseModel {
    // MARK: Keys
    private let kText: String = "text"
    private let kStartsAt: String = "startsAt"
    private let kEndsAt: String = "endsAt"
    // MARK: Properties
    public var text:String?
    public var starstAt:Int?
    public var endsAt:Int?
    
    // MARK: Initializers
    public override init() {
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        if let value = json[kText].string{
            text = value
        }
        if let value = json[kStartsAt].int{
            starstAt = value
        }
        if let value = json[kEndsAt].int{
            endsAt = value
        }
    }
    
    public override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        // text
        if let value = text {
            dictionary[kText] = value
        }
        // start index
        if let value = starstAt {
            dictionary[kStartsAt] = value
        }
        // end index
        if let value = endsAt {
            dictionary[kEndsAt] = value
        }
        return dictionary
    }
}
