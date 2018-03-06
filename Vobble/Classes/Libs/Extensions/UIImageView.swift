//
//  UIView.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 6/13/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func setImageForURL(_ url: String, placeholder: UIImage?) {
        self.image = placeholder
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
        self.sd_setImage(with: URL(string: url))
    }
}
