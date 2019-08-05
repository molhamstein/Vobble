//
//  AppDelegate.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import Firebase
import Crashlytics
import Fabric
import OneSignal
import Flurry_iOS_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    var window: UIWindow?

    // MARK: Application Cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if (AppConfig.useCurrentLocation) {
            LocationHelper.shared.startUpdateLocation()
        }
        // set navigation style
        AppConfig.setNavigationStyle()
        // init social managers
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        TWTRTwitter.sharedInstance().start(withConsumerKey: AppConfig.twitterConsumerKey, consumerSecret: AppConfig.twitterConsumerSecret)
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = !AppConfig.isProductionBuild
        //FirebaseCrash
        //FirebaseConfiguration.sharedInstance().crashCollectionEnabled = AppConfig.isProductionBuild
        // init managers
//        DataStore.shared
//        FirebaseManager.shared
        
        // init notification
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
//            print("Message = \(payload!.body)")
//            print("badge number = \(payload?.badge ?? 0)")
//            print("notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData {
                
                print("additionalData = \(additionalData)")
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                if let chatId = additionalData["chatId"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if DataStore.shared.isLoggedin {
                            ActionOpenChat.execute(chatId: chatId, conversation: nil)
                        }
                    }
                } else if let _ = additionalData["throwBottle"] as? String {
                    // broadcast
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if DataStore.shared.isLoggedin {
                            NotificationCenter.default.post(name: Notification.Name("OpenThrowBottle"), object: nil)
                        }
                    }
                } else if let bottleId = additionalData["bottleId"] as? String {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if DataStore.shared.isLoggedin {
                            NotificationCenter.default.post(name: Notification.Name("OpenBottleById"), object: bottleId)
                        }
                    }
                    //                        self.window?.rootViewController = instantiatedGreenViewController
                    //                        self.window?.makeKeyAndVisible()
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    // For presenting a ViewController from push notification action button
//                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let instantiateRedViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RedViewControllerID") as UIViewController
//                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GreenViewControllerID") as UIViewController
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    
                    print("actionID = \(actionID)")
                    
                }
            }
            
        }
        
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: AppConfig.oneSingleID,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        // flurry
        Flurry.startSession("7B59N7DQJQKHKGVY9BJ8", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) ||
            TWTRTwitter.sharedInstance().application(app, open: url, options: options) ||
            GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataStore.shared.versionChecked = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataStore.shared.versionChecked = false
    }
    
}

