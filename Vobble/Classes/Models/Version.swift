//
//  Version.swift
//  Vobble
//
//  Created by Abd Hayek on 8/4/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

enum VersionStatus: String {
    case obsolete = "obsolete"
    case updateAvailable = "update available"
    case upToDate = "uptodate"
}

class Version: BaseModel {
    
    // MARK: Keys
    private let kStatus: String = "status"
    private let kLink: String = "link"
    
    // MARK: Properties
    public var status: VersionStatus?
    public var link: String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kStatus].string {
            status = VersionStatus(rawValue: value)
        }
        if let value = json[kLink].string {
            link = value
        }
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        
        if let value = status?.rawValue {
            dictionary[kStatus] = value
        }
        if let value = link {
            dictionary[kLink] = value
        }
        return dictionary
    }
    
}
