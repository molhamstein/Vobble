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
    @IBOutlet weak var rightIcon: UIButton!
    public var viewcontroller : UIViewController?
    
    /// set navigation title when navigationTitle is visible.
    @IBInspectable open var title: String = "" {
        didSet {
            setNavTitle(title: title)
        }
    }
    
    /// set left image icon when image_name is visible.
    @IBInspectable open var left_image: UIImage? {
        didSet {
            setLeftIcon(image: left_image)
        }
    }
    
    /// set right image icon when image_name is visible.
    @IBInspectable open var right_image: UIImage? {
        didSet {
            setRightIcon(image: right_image)
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
   
    // set left icon
    fileprivate func setRightIcon (image: UIImage?) {
        
        if let img = image {
            rightIcon.setImage(img, for: .normal)
        }
    }
    
    @IBAction func leftIconPressed(_ sender: Any) {
        if leftIcon.currentImage == UIImage(named: "navBackIcon") {
            if let nc = viewcontroller?.navigationController, viewcontroller == nc.viewControllers[0] {
                nc.dismiss(animated: true, completion: {})
            } else {
                viewcontroller?.dismiss(animated: true, completion: nil)
            }
        } else if leftIcon.currentImage == UIImage(named: "filters") {
            let vc = viewcontroller as! HomeViewController
            vc.showFilter()
        }
    }
    
    @IBAction func rightIconPressed(_ sender: Any) {
        
        let vc = viewcontroller as! HomeViewController
        vc.showShopView()
    }
    
    
}
