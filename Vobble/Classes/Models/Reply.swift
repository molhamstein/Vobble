//
//  Reply.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/10/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

class Reply: Comment {
    // MARK: Keys
    private let kComment: String = "originalComment"
    
    // MARK: Properties
    public var comment:Comment?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        if (json[kComment] != JSON.null) {
            comment = Comment(json: json[kComment])
        }
        repliesCount = nil
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        if let value = comment {
            dictionary[kComment] = value.dictionaryRepresentation()
        }
        return dictionary
    }
}
