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
    @objc optional func moreOptionsBtnPressed()
    @objc optional func extendChatBtnPressed()
}

class VobbleChatNavigationBar: AbstractNibView {
    
    @IBOutlet weak var btnExtendChat: UIButton!
    @IBOutlet weak var moreOptions: UIButton!
    @IBOutlet weak var leftIcon: UIButton!
    @IBOutlet weak var timerLabel: TimerLabel!
    public weak var viewcontroller : UIViewController?
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shoreNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var extendChatLabel: UILabel!
    @IBOutlet weak var extendAlertView: UIView!
    
    weak var delegate:ChatNavigationDelegate?

    /// set left image icon when image_name is visible.
    @IBInspectable open var left_image: UIImage? {
        didSet {
            setLeftIcon(image: left_image)
        }
    }
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.btnExtendChat.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.btnExtendChat.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.btnExtendChat.layer.shadowRadius = 12
        self.btnExtendChat.layer.shadowOpacity = 1
        self.extendAlertView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.extendAlertView.frame.height - 50)
    }
    
    // MARK: -  Private Methods
    
    // set left icon
    fileprivate func setLeftIcon (image: UIImage?) {
        
        if let img = image {
            leftIcon.setImage(img, for: .normal)
        }
    }
 
    @IBAction func moreOptionsPressed(_ sender: Any) {
        self.delegate?.moreOptionsBtnPressed?()
    }
    
    @IBAction func extendChatPressed(_ sender: Any) {
        self.delegate?.extendChatBtnPressed?()
    }
    
    @IBAction func leftIconPressed(_ sender: Any) {
//        if leftIcon.currentImage == UIImage(named: "navBackIcon") {
//            viewcontroller?.dismiss(animated: true, completion: nil)
//        }
        self.delegate?.navLeftBtnPressed?()
    }

}
