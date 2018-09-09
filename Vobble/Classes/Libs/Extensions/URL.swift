//
//  String.swift
//  
//
//  Created by Molham Mahmoud on 02/09/18.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import UIKit

extension URL {
    
    func isValidUrl() -> Bool {
        return UIApplication.shared.canOpenURL(self)
    }
    
}
