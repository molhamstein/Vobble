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
            var ding:AVAudioPlayer = AVAudioPlayer()
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


