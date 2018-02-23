//
//  VobbleButton.swift
//  Vobble
//
//  Created by Bayan on 2/20/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

open class VobbleButton : RNLoadingButton {
 
    
    // MARK: - Initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        setShadow()
        setCornerRadius()
        
    }
    
    
    /// set gradient when gradient is visible.
    @IBInspectable open var gradient: Bool = false {
        didSet {
            setGradient()
        }
    }
    
    /// set image icon when image_name is visible.
    @IBInspectable open var image_name: UIImage? {
        didSet {
             setLeftImage(imageName: image_name)
        }
    }
    
    
    // MARK: -  Private Methods
    
    fileprivate func setShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 7.0
        self.layer.masksToBounds = false
    }
    
    fileprivate func setCornerRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1
    }
    
    fileprivate func setGradient() {
        
        if (self.gradient) {
            
            applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], locations: [0.0, 1.0])
        }
        
    }

    fileprivate func setLeftImage(imageName:UIImage?) {
        if let image = imageName {
           //Set left image
           self.setImage(image, for: .normal)
           //Calculate and set image inset to keep it left aligned
           let imageWidth = image.size.width
           let textWidth = self.titleLabel?.intrinsicContentSize.width
           let buttonWidth = self.bounds.width
        
           let padding:CGFloat = 30.0
           let rightInset = buttonWidth - imageWidth  - textWidth! - padding
        
           self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: rightInset)
        }
    }
    
}
