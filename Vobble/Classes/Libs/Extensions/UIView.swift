//
//  UIView.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 6/13/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

enum GradientDirection {
    case horizontal
    case vertical
    case diagonal
    
}

extension UIView {
    /// add **touch up selector** to any **view**
    ///
    /// Usage:
    ///
    ///     view.tapAction{print("View tapped!")}
    ///
    /// - Parameters: 
    ///     - closure: The block to be excuted when tapping.
    func tapAction( _ closure: @escaping ()->()){
        self.isUserInteractionEnabled = true
        let sleeve = ClosureSleeve(closure)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: sleeve, action: #selector(ClosureSleeve.invoke))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    /// Fade the current view in
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    /// Fade the current view out
    func fadeOut() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    /// set shadow to current view
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 12
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }
    
    func dropShortShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 8
        layer.cornerRadius = 8
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }
    
    func bringToFront() {
        self.superview?.bringSubview(toFront: self)
    }
    
    /// set gradient to current view
    func applyGradient(colours: [UIColor], direction: GradientDirection) -> Void {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = [0.0,1.0]
        gradient.borderColor = self.layer.borderColor
        gradient.borderWidth = self.layer.borderWidth
        gradient.cornerRadius = self.layer.cornerRadius
        
        if direction == .horizontal {
            
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
            
        } else if direction == .vertical {
            
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
            
        } else if direction == .diagonal {
            
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
            
        }
        self.layer.insertSublayer(gradient, at:0)
    }
    
    
    func removeGradientLayer() {
        if let lastLayer = self.layer.sublayers?[0] as? CAGradientLayer {
            lastLayer.removeFromSuperlayer()
        }
    }
    
    /// set corner radius from interface builder
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// set border width from interface builder
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// set border color from interface builder
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor.init(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }

}

enum AnimationType {
    case animateInFromBottom
    case animateInFromTop
    case animateInFromRight
    case animateInFromLeft
    case animateOutToBottom
    case animateOutToTop
    case animateOutToRight
    case animateOutToLeft
}

extension UIView {
    
    public static let animDurationLong = 1.0
    public static let animDurationShort = 0.5
    
    private static let animDist: CGFloat = 100.0
    
    func animateIn(mode: AnimationType, delay: CFTimeInterval) {
        var initialTransform: CGAffineTransform = CGAffineTransform.identity
        var finalTransform: CGAffineTransform = CGAffineTransform.identity
        let initialAlpha: CGFloat
        let finalAlpha: CGFloat
        
        switch mode {
        case .animateInFromBottom:
            initialTransform = CGAffineTransform(translationX: 0, y: UIView.animDist)
        case .animateInFromTop:
            initialTransform = CGAffineTransform(translationX: 0, y: -UIView.animDist)
        case .animateInFromRight:
            initialTransform = CGAffineTransform(translationX: UIView.animDist, y: 0)
        case .animateInFromLeft:
            initialTransform = CGAffineTransform(translationX: -UIView.animDist, y: 0)
        case .animateOutToBottom:
            finalTransform = CGAffineTransform(translationX: 0, y: UIView.animDist)
        case .animateOutToTop:
            finalTransform = CGAffineTransform(translationX: 0, y: -UIView.animDist)
        case .animateOutToRight:
            finalTransform = CGAffineTransform(translationX: UIView.animDist, y: 0)
        case .animateOutToLeft:
            finalTransform = CGAffineTransform(translationX: -UIView.animDist, y: 0)
        }
        
        switch mode {
        case .animateInFromLeft,
             .animateInFromRight,
             .animateInFromTop,
             .animateInFromBottom:
            finalTransform = CGAffineTransform.identity
            initialAlpha = 0
            finalAlpha = 1
        case .animateOutToLeft,
             .animateOutToRight,
             .animateOutToBottom,
             .animateOutToTop:
            initialTransform = CGAffineTransform.identity
            initialAlpha = 1
            finalAlpha = 0
        }
        
        self.alpha = initialAlpha
        self.transform = initialTransform
        UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.alpha = finalAlpha
            self.transform = finalTransform
        }) { _ in
            
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position : CGPoint = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        self.layer.position = position;
        self.layer.anchorPoint = anchorPoint;
    }
}
