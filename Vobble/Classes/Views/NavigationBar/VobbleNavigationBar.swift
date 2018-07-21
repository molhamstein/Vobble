//
//  VobbleNavigationBar.swift
//  Vobble
//
//  Created by Bayan on 2/21/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit
import Flurry_iOS_SDK

class VobbleNavigationBar : AbstractNibView {
    
    enum NavBarMode{
        case home
        case normal
    }
    
    @IBOutlet weak var leftIcon: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var rightIcon: UIButton!
    public weak var viewcontroller : UIViewController?
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var mode:NavBarMode = .normal
    
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
        setupView()
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView () {
        navTitle.font = AppFonts.bigBold
        progressIndicator.isHidden = true
        
        if AppConfig.currentLanguage == .arabic {
            rightIcon.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -5)
            leftIcon.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 8)
        } else {
            leftIcon.transform = CGAffineTransform.identity
            rightIcon.transform = CGAffineTransform.identity
        }
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
    
    func showProgressIndicator(show: Bool){
        if show {
            progressIndicator.startAnimating()
        } else {
            progressIndicator.stopAnimating()
        }
        progressIndicator.isHidden = !show
    }
    
    @IBAction func leftIconPressed(_ sender: Any) {
        if mode != .home {
            if let nc = viewcontroller?.navigationController, viewcontroller == nc.viewControllers[0] {
                nc.dismiss(animated: true, completion: {})
            } else {
                viewcontroller?.dismiss(animated: true, completion: nil)
            }
        } else if mode == .home {
            let vc = viewcontroller as! HomeViewController
            vc.showFilter(self)
        }
    }
    
    @IBAction func rightIconPressed(_ sender: Any) {
        
        if let vc = viewcontroller as? HomeViewController {
            let logEventParams = ["From": "TopButton"];
            Flurry.logEvent(AppConfig.shop_enter, withParameters:logEventParams);
            vc.showShopView(.bottlesPack)
        }
    }
    
}
