//
//  VobbleChatNavigationController.swift
//  Vobble
//
//  Created by Bayan on 3/22/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ChatNavigationDelegate {
    @objc optional func navLeftBtnPressed()
    @objc optional func navRightBtnPressed()
}

class VobbleChatNavigationBar: AbstractNibView {
    
    @IBOutlet weak var leftIcon: UIButton!
    @IBOutlet weak var timerLabel: TimerLabel!
    public var viewcontroller : UIViewController?
    
    var delegate:ChatNavigationDelegate?

    /// set left image icon when image_name is visible.
    @IBInspectable open var left_image: UIImage? {
        didSet {
            setLeftIcon(image: left_image)
        }
    }
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: -  Private Methods
    
    // set left icon
    fileprivate func setLeftIcon (image: UIImage?) {
        
        if let img = image {
            leftIcon.setImage(img, for: .normal)
        }
    }
 
    @IBAction func leftIconPressed(_ sender: Any) {
//        if leftIcon.currentImage == UIImage(named: "navBackIcon") {
//            viewcontroller?.dismiss(animated: true, completion: nil)
//        }
        self.delegate?.navLeftBtnPressed?()
    }

}
