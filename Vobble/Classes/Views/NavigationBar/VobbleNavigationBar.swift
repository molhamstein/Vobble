//
//  VobbleNavigationBar.swift
//  Vobble
//
//  Created by Bayan on 2/21/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit

class VobbleNavigationBar : AbstractNibView {
    
    @IBOutlet weak var leftIcon: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    public var viewcontroller : UIViewController?
    
    /// set navigation title when navigationTitle is visible.
    @IBInspectable open var title: String = "" {
        didSet {
            setNavTitle(title: title)
        }
    }
    
    /// set left image icon when image_name is visible.
    @IBInspectable open var imageName: UIImage? {
        didSet {
            setLeftIcon(image: imageName)
        }
    }
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: -  Private Methods
    
    // set navigation title
    fileprivate func setNavTitle (title: String) {
        navTitle.text = title
    }
    
    // set left icon
    fileprivate func setLeftIcon (image: UIImage?) {
        
        if let img = image {
           leftIcon.setImage(img, for: .normal)
        }
    }
    
    @IBAction func leftIconPressed(_ sender: Any) {
        viewcontroller?.dismiss(animated: true, completion: nil)
    }
    
}
