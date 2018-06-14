//
//  InventoryItem.swift
//  Vobble
//
//  Created by Molham mahmoud on 5/31/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class InventoryItem: BaseModel {
    
    // MARK: Keys
    private let kInventoryItemId: String = "id"
    private let kInventoryIsValid: String = "name_en"
    private let kInventoryIsConsumed: String = "name_ar"
    private let kInventoryPorduct: String = "Product"
    private let kInventoryStartDate: String = "startDate"
    private let kInventoryEndDate: String = "EndDate"
    
    // MARK: Properties
    public var objectId : String?
    public var isValid : Bool?
    public var isConsumed : Bool?
    public var shopItem : ShopItem?
    public var startDate : Double?
    public var endDate : Double?

    public var type: ShopItemType? {
        get {
            return shopItem?.type
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kInventoryItemId].string {
            objectId = value
        }
        if let value = json[kInventoryIsValid].bool {
            isValid = value
        }
        if let value = json[kInventoryIsConsumed].bool {
            isConsumed = value
        }
        if json[kInventoryPorduct] != JSON.null {
            shopItem = ShopItem(json: json[kInventoryPorduct])
        }
        if let value = json[kInventoryEndDate].double {
            endDate = value
        }
        if let value = json[kInventoryStartDate].double {
            startDate = value
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = objectId {
            dictionary[kInventoryItemId] = value
        }
        
        if let value = isValid {
            dictionary[kInventoryIsValid] = value
        }
        if let value = isConsumed {
            dictionary[kInventoryIsConsumed] = value
        }
        
        if let value = shopItem {
            dictionary[kInventoryItemId] = value.dictionaryRepresentation()
        }
        
        if let value = endDate {
            dictionary[kInventoryEndDate] = value
        }
        
        if let value = startDate {
            dictionary[kInventoryStartDate] = value
        }
        
        return dictionary
    }
    
}
