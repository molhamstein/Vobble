//
//  UIApplication.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/4/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation

extension UIApplication
{
    static func keyWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    static func appWindow() -> UIWindow {
        if let window: UIWindow = (UIApplication.shared.delegate?.window)!{
            return window
        }
        return UIWindow()
    }
    
    static func rootViewController() -> UIViewController?{
        return self.appWindow().rootViewController
    }

    static func visibleViewController() -> UIViewController?{
        return self.rootViewController()?.findContentViewControllerRecursively()
    }
    
    static func visibleNavigationController() -> UINavigationController?{
        return self.visibleViewController()?.navigationController
    }
    
    static func visibleTabBarController() -> UITabBarController? {
    return self.visibleViewController()?.tabBarController
    }
    
    static func visibleSplitViewController() -> UISplitViewController? {
        return self.visibleViewController()?.splitViewController
    }
    
    static func pushOrPresentViewController(viewController: UIViewController, animated:Bool) {
        if let nav:UINavigationController = self.visibleNavigationController() {
            nav.pushViewController(viewController, animated: animated)
        } else {
            self.visibleViewController()?.present(viewController, animated: animated, completion: nil)
        }
    }

}
