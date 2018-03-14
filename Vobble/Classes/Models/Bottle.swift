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
    private let kBottleName: String = "name"
    private let kBottleCountry: String = "country"
    private let kBottleTime: String = "time"
    private let kBottleFirstColor: String = "fcolor"
    private let kBottleSecondColor: String = "lcolor"
    private let kBottleImageUrl: String = "imgurl"
    
    
    // MARK: Properties
    public var idString : String?
    public var name : String?
    public var country : String?
    public var time : String?
    public var firstColor : UIColor?
    public var secondColor : UIColor?
    public var imageUrl : UIImage?
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kBottleId].string {
            idString = value
        }
        if let value = json[kBottleName].string {
            name = value
        }
        if let value = json[kBottleCountry].string {
            country = value
        }
        if let value = json[kBottleTime].string {
            time = value
        }
//                if let value = json[kBottleFirstColor].string {
//                    firstColor = value
//                }
//                if let value = json[kBottleSecondColor].string {
//                    secondColor = value
//                }
//        set image
//                if let value = json[kBottleImageUrl].string {
//                    imageUrl = value
//                }
        
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = idString {
            dictionary[kBottleId] = value
        }
        
        if let value = name {
            dictionary[kBottleName] = value
        }
        
        if let value = country {
            dictionary[kBottleCountry] = value
        }
        
        if let value = time {
            dictionary[kBottleTime] = value
        }
        
        if let value = firstColor {
            dictionary[kBottleFirstColor] = value
        }
        
        if let value = secondColor {
            dictionary[kBottleSecondColor] = value
        }
        
        //        if let value = imageUrl {
        //            dictionary[kBottleImageUrl] = value
        //        }
        
        return dictionary
    }
    
}
