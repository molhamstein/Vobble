//
//  UIViewController.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/4/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation

extension UIViewController{
    
    func findContentViewControllerRecursively() -> UIViewController? {
    var childViewController: UIViewController?
    if let tabBarController:UITabBarController = self as? UITabBarController{
        childViewController = tabBarController.selectedViewController
    } else if let navigationContoller :UINavigationController = self as? UINavigationController {
        childViewController = navigationContoller.topViewController
    } else if let splitViewController:UISplitViewController = self as? UISplitViewController {
        childViewController = splitViewController.viewControllers.last
    } else if self.presentedViewController != nil {
        childViewController = self.presentedViewController
    }
    // FIXME: UIAlertController is a kludge and should be removed
    let shouldContinueSearch: Bool  = (childViewController != nil) && !childViewController!.isKind(of: UIAlertController.self)
    return shouldContinueSearch ? childViewController?.findContentViewControllerRecursively() : self
    }
    
    func isPresentedModally() -> Bool {
        return self.presentingViewController?.presentedViewController == self
    }
    
    func popOrDismissViewControllerAnimated(animated: Bool){
        if (self.isPresentedModally()) {
            self.dismiss(animated: animated, completion: nil)
        } else if (self.navigationController != nil) {
//            if self.navigationController?.viewControllers[0] == self {
//                self.navigationController?.dismiss(animated: true, completion: {})
//            } else {
            self.navigationController?.popViewController(animated: animated)
//            }
        }
    }
}

