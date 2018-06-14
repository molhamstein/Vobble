//
//  Actions.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import StoreKit

/**
Repeated and generic actions to be excuted from any context of the app such as show alert
 */
class Action: NSObject {
    class func execute() {
    }
}

class ActionLogout:Action {
    override class func execute() {
        let cancelButton = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: "SETTINGS_USER_LOGOUT".localized, style: .default, handler: {
            (action) in
            //clear user
            DataStore.shared.logout()
            ActionShowStart.execute()
        })
        let alert = UIAlertController(title: "SETTINGS_USER_LOGOUT".localized, message: "SETTINGS_USER_LOGOUT_CONFIRM_MSG".localized, preferredStyle: .alert)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let controller = UIApplication.visibleViewController() {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}

class ActionShowStart: Action {
    override class func execute() {
        UIApplication.appWindow().rootViewController = UIStoryboard.startStoryboard.instantiateViewController(withIdentifier: StartViewController.className)
    }
}

class ActionShowProfile: Action {
    override class func execute() {
        let profileViewController = UIStoryboard.profileStoryboard.instantiateViewController(withIdentifier: ProfileViewController.className)
        UIApplication.pushOrPresentViewController(viewController: profileViewController, animated: true)
    }
}

class ActionRateUs {
    class func execute(hostViewController: UIViewController!) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        } else {
            let rateViewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: RateUsPopupViewController.className)
            rateViewController.providesPresentationContextTransitionStyle = true
            rateViewController.definesPresentationContext = true
            rateViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            rateViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            hostViewController.present(rateViewController, animated: true, completion: nil)
        }
            //UIApplication.pushOrPresentViewController(viewController: profileViewController, animated: true)
    }
}

class ActionShareText {
    class func execute(viewController: UIViewController, text: String, sourceView: UIView){
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sourceView
        viewController.present(activityVC, animated: true, completion: nil)
    }
}


