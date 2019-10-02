//
//  Actions.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import StoreKit
import AVFoundation
import UserNotifications

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
            
            //clear notification
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            } else {
                // Fallback on earlier versions
            }
            
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

class ActionOpenChat{
    class func execute(chatId: String, conversation: Conversation?, inNavigationController: UINavigationController? = nil) {
        let chatViewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ChatViewControllerID") as! ChatViewController
        chatViewController.conversationId = chatId
        chatViewController.conversationOriginalObject = conversation
        if let navController = inNavigationController {
            navController.pushViewController(chatViewController, animated: true)
        } else {
            UIApplication.pushOrPresentViewController(viewController: chatViewController, animated: true)
        }
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

class ActionShowSharePopup {
    class func execute(hostViewController: UIViewController!) {
        let shareViewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: ShareAppPopupViewController.className) as! ShareAppPopupViewController
        shareViewController.providesPresentationContextTransitionStyle = true
        shareViewController.definesPresentationContext = true
        shareViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        shareViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
        shareViewController.hostViewController = hostViewController
        hostViewController.present(shareViewController, animated: true, completion: nil)
    }
}

class ActionShareText {
    class func execute(viewController: UIViewController, text: String, sourceView: UIView){
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sourceView
        viewController.present(activityVC, animated: true, completion: nil)
    }
}

class ActionCompressVideo {
    class func execute(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

class ActionPlayBeep{
    class func execute() {
        do {
            var ding:AVAudioPlayer!
            let path = Bundle.main.path(forResource: "audio_msg_beeb", ofType: "mp3")
            ding = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            ding.prepareToPlay()
            ding.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

class ActionDeactiveUser {
    class func execute(viewController: UIViewController, user: AppUser?, error: ServerError?) -> Bool {
        
        if user?.status == .deactivated {
            // Kick the user out
            let alert = UIAlertController(title: "GLOBAL_ERROR_TITLE".localized, message: "DEACTIVE_MSG".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: {_ in
                //clear user
                DataStore.shared.logout()
                ActionShowStart.execute()
            }))
            viewController.present(alert, animated: true, completion: nil)
            
            return false
        } else if let err = error, (err.type == .accountDeactivated || err.type == .deviceBlocked) {
            let alert = UIAlertController(title: "GLOBAL_ERROR_TITLE".localized, message: err.type.errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: {_ in
                //clear user
                DataStore.shared.logout()
                ActionShowStart.execute()
            }))
            viewController.present(alert, animated: true, completion: nil)
            return false
        } else {
            
            return true
        }
    }
}

class ActionCheckForUpdate {
    class func execute(viewController: UIViewController) {
        if let versionStatus = DataStore.shared.me?.version?.status {
            let alert = UIAlertController(title: "GLOBAL_WARNING_TITLE".localized, message: nil, preferredStyle: .alert)
            let updateAction = UIAlertAction(title: "UPDATE".localized, style: .default, handler: {_ in
                guard let url = URL(string: DataStore.shared.me?.version?.link?.replacingOccurrences(of: "\\", with: "") ?? "") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            })
            let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
            
            
            switch versionStatus {
                case .obsolete:
                    alert.title = "GLOBAL_HEAD_UP_TITLE".localized
                    alert.message = "VERSION_OBSOLETE".localized
                    alert.addAction(updateAction)
                    viewController.present(alert, animated: true, completion: nil)
                
                case .updateAvailable:
                    alert.title = "GLOBAL_WARNING_TITLE".localized
                    alert.message = "VERSION_AVAILABLE".localized
                    alert.addAction(updateAction)
                    alert.addAction(cancelAction)
                    
                    if !DataStore.shared.versionChecked {
                        DataStore.shared.versionChecked = true
                        viewController.present(alert, animated: true, completion: nil)
                    }
                
                
                case .upToDate:
                    return
            }
        }

    }
}

class ActionRegisterNotification {
    class func execute(conversation: Conversation?) {
        if #available(iOS 10.0, *) {
            guard let conversation = conversation else { return }
            
            // Remove previous registered notification if found
            ActionRemoveNotification.execute(id: conversation.idString ?? "")
            
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            let strBody = String.init(format: "CHAT_WARNING_BODY".localized, conversation.getPeer?.userName ?? "")
            content.title = "CHAT_WARNING_TITLE".localized
            content.body = strBody
            content.categoryIdentifier = conversation.idString ?? ""
            content.sound = UNNotificationSound.default()
            
            var seconds = 0.0
            if let fTime = conversation.finishTime {
                let currentDate = Date().timeIntervalSince1970 * 1000
                seconds = ((fTime - currentDate) / 1000.0) - 7200
            }
            
            if seconds > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
                
                let request = UNNotificationRequest(identifier: conversation.idString ?? UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        
    }
}

class ActionRemoveNotification {
    class func execute(id: String) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.removePendingNotificationRequests(withIdentifiers: [id])
        } else {
            // Fallback on earlier versions
        }
        
        
    }
}
