//
//  ReportType.swift
//  Vobble
//
//  Created by Molham mahmoud on 5/31/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

import SwiftyJSON

class ReportType: BaseModel {
    
    // MARK: Keys
    private let kReportId: String = "id"
    private let kname_en: String = "reportName_en"
    private let kname_ar: String = "reportName_ar"
    
    // MARK: Properties
    public var objectId:String?
    public var name_ar:String?
    public var name_en:String?
    
    public var name: String? {
        get {
            return AppConfig.currentLanguage == .arabic ? name_ar : name_en
        }
    }
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kReportId].string {
            objectId = value
        }
        if let value = json[kname_ar].string {
            name_ar = value
        }
        
        if let value = json[kname_en].string {
            name_en = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = objectId {
            dictionary[kReportId] = value
        }
        if let value = name_ar {
            dictionary[kname_ar] = value
        }
        if let value = name_en {
            dictionary[kname_en] = value
        }
        return dictionary
    }
    
}
