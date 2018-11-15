//
//  Constants.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 12/25/16.
//  Copyright © 2016 . All rights reserved.
//
import UIKit


// MARK: Application configuration
struct AppConfig {
    
    // domain
    //static let appBaseDevURL = "https://brain-socket.com/dev"
    //static let appBaseDevURL = "https://vobble.herokuapp.com/api"
    static let appBaseDevURL = "http://104.217.253.15:7000/api"
    static let appBaseLiveURL = "http://159.65.202.38:3000/api"
    static let useLiveAPI: Bool = true
    static let isProductionBuild: Bool = false
    static let useCurrentLocation: Bool = false
    static let contactUsEmail: String = "yallavideoapp@gmail.com"
    
    // social
    static let instagramClienID = "99366a1b59984cffb7e99bb8c9c7fda8"
    static let instagramRedirectURI = "http://brain-socket.com"
    static let twitterConsumerKey = "eq0dVMoM1JqNcR6VJJILsdXNddo"
    static let twitterConsumerSecret = "6JkdvzSijm13xjBW0fYSEG4yF2tbro8pwxz1vDx290Bj0aMw2vssI"
    static let googleClientID = "82142364137-21s23clufpu4d0abp5ppa5na245tak1u.apps.googleusercontent.com"
//    static let oneSingleID = "3754a01e-b355-4248-a906-e04549e6ab32"
    static let oneSingleID = "e8a91e90-a766-4f1b-a47e-e3b3f569dbef"
    
    static let AppleStoreAppId = "3754a01e-b355-4248-a906-e04549e6ab32"
    
    static let PlaceHolderImage = UIImage(named: "bottle-1")
    
    static let DATE_SERVER_DATES_LOCALE = "en_US_POSIX"
    
    static let NO_COUNTRY_SELECTED = "none"
    
    // tracking events
    // find
    static let find_bottle = "Find_Bottle"
    static let find_bottle_not_found = "Find_Bottle_Not_Found"
    // reply
    static let reply_pressed = "Reply_Pressed"
    static let reply_shooted = "Reply_Shooted"
    static let reply_submitted = "Reply_Submitted"
    static let reply_ignored = "Reply_Ignored"
    
    // throw
    static let throw_bottle = "Throw_Clicked"
    static let throw_shore_selected = "Throw_Shore_Selected"
    
    // record. works for both reply_record and for throw_record
    static let recorded_video = "Recorded_video"
    
    // shop
    static let shop_enter = "Enter_Shop"
    // shop select product, select product properties
    static let shop_select_product = "Select_Shop_Product"
    // Shop purchase
    static let shop_purchase_click = "Shop_Purchase_Clicked"
    static let shop_purchase_complete = "Shop_Purchase_Complete"
    
    // Filter
    static let filter_click = "Filter_Click"
    
    static let chatValidityafterSeen: Double = 24.0*60.0*60.0*1000.0 // 24 hours
    
    // validation
    static let passwordLength = 6
    
    // current application language
    static var currentLanguage:AppLanguage {
        let locale = NSLocale.current.languageCode
        if (locale == "ar") {
            return .arabic
        }
        return .english
    }
    
    /// Set navigation bar style, text and color
    static func setNavigationStyle() {
        
        // set background color
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UIBarButtonItem.appearance().tintColor = AppColors.blueXDark
        //Since iOS 7.0 UITextAttributeTextColor was replaced by NSForegroundColorAttributeName
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: AppColors.blueXDark]
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    static func getBottlePath() -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 115.3, y: 46.6))
        bezierPath.addCurve(to: CGPoint(x: 111, y: 33.6), controlPoint1: CGPoint(x: 111.8, y: 44), controlPoint2: CGPoint(x: 111, y: 33.6))
        bezierPath.addLine(to: CGPoint(x: 110.4, y: 17))
        bezierPath.addLine(to: CGPoint(x: 110.4, y: 17))
        bezierPath.addLine(to: CGPoint(x: 110.4, y: 17))
        bezierPath.addLine(to: CGPoint(x: 110.4, y: 16.5))
        bezierPath.addCurve(to: CGPoint(x: 111, y: 15.3), controlPoint1: CGPoint(x: 110.4, y: 16.5), controlPoint2: CGPoint(x: 111, y: 16.4))
        bezierPath.addCurve(to: CGPoint(x: 110.1, y: 12.6), controlPoint1: CGPoint(x: 111, y: 14), controlPoint2: CGPoint(x: 111.2, y: 12.6))
        bezierPath.addCurve(to: CGPoint(x: 110, y: 10.7), controlPoint1: CGPoint(x: 110, y: 12.6), controlPoint2: CGPoint(x: 110, y: 10.7))
        bezierPath.addCurve(to: CGPoint(x: 109.3, y: 9.8), controlPoint1: CGPoint(x: 110, y: 10.1), controlPoint2: CGPoint(x: 109.6, y: 9.9))
        bezierPath.addLine(to: CGPoint(x: 109.3, y: 5.8))
        bezierPath.addLine(to: CGPoint(x: 109.3, y: 5.8))
        bezierPath.addLine(to: CGPoint(x: 109.3, y: 5))
        bezierPath.addLine(to: CGPoint(x: 109.3, y: 1.5))
        bezierPath.addCurve(to: CGPoint(x: 104.3, y: 0.1), controlPoint1: CGPoint(x: 109.3, y: 0.7), controlPoint2: CGPoint(x: 107, y: 0.1))
        bezierPath.addCurve(to: CGPoint(x: 99.2, y: 1.5), controlPoint1: CGPoint(x: 101.5, y: 0.1), controlPoint2: CGPoint(x: 99.2, y: 0.7))
        bezierPath.addLine(to: CGPoint(x: 99.2, y: 10))
        bezierPath.addCurve(to: CGPoint(x: 98.8, y: 10.7), controlPoint1: CGPoint(x: 98.8, y: 10.3), controlPoint2: CGPoint(x: 98.8, y: 10.7))
        bezierPath.addCurve(to: CGPoint(x: 98.8, y: 12.6), controlPoint1: CGPoint(x: 98.8, y: 10.7), controlPoint2: CGPoint(x: 98.8, y: 11.7))
        bezierPath.addCurve(to: CGPoint(x: 97.8, y: 13.3), controlPoint1: CGPoint(x: 97.9, y: 12.6), controlPoint2: CGPoint(x: 97.8, y: 13.3))
        bezierPath.addCurve(to: CGPoint(x: 97.8, y: 15.4), controlPoint1: CGPoint(x: 97.8, y: 13.3), controlPoint2: CGPoint(x: 97.8, y: 14.3))
        bezierPath.addCurve(to: CGPoint(x: 98.5, y: 16.7), controlPoint1: CGPoint(x: 97.8, y: 16.5), controlPoint2: CGPoint(x: 98.5, y: 16.7))
        bezierPath.addLine(to: CGPoint(x: 98.5, y: 16.7))
        bezierPath.addLine(to: CGPoint(x: 98.5, y: 17.2))
        bezierPath.addLine(to: CGPoint(x: 98.5, y: 17.2))
        bezierPath.addLine(to: CGPoint(x: 98.4, y: 33.7))
        bezierPath.addCurve(to: CGPoint(x: 93.7, y: 46.7), controlPoint1: CGPoint(x: 98.5, y: 42.1), controlPoint2: CGPoint(x: 95.9, y: 44.7))
        bezierPath.addCurve(to: CGPoint(x: 85.9, y: 60), controlPoint1: CGPoint(x: 87.8, y: 50.8), controlPoint2: CGPoint(x: 85.9, y: 60))
        bezierPath.addLine(to: CGPoint(x: 85.9, y: 137.5))
        bezierPath.addCurve(to: CGPoint(x: 103.6, y: 140.1), controlPoint1: CGPoint(x: 85.9, y: 137.5), controlPoint2: CGPoint(x: 90, y: 140))
        bezierPath.addCurve(to: CGPoint(x: 104, y: 140.1), controlPoint1: CGPoint(x: 103.8, y: 140.1), controlPoint2: CGPoint(x: 104, y: 140.1))
        bezierPath.addCurve(to: CGPoint(x: 104.2, y: 140.1), controlPoint1: CGPoint(x: 104, y: 140.1), controlPoint2: CGPoint(x: 104, y: 140.1))
        bezierPath.addCurve(to: CGPoint(x: 104.5, y: 140.1), controlPoint1: CGPoint(x: 104.3, y: 140.1), controlPoint2: CGPoint(x: 104.4, y: 140.1))
        bezierPath.addCurve(to: CGPoint(x: 123.4, y: 137.5), controlPoint1: CGPoint(x: 120.3, y: 140.1), controlPoint2: CGPoint(x: 123.4, y: 137.5))
        bezierPath.addCurve(to: CGPoint(x: 123.4, y: 60), controlPoint1: CGPoint(x: 123.4, y: 137.5), controlPoint2: CGPoint(x: 123.4, y: 66.3))
        bezierPath.addCurve(to: CGPoint(x: 115.3, y: 46.6), controlPoint1: CGPoint(x: 123.5, y: 53.6), controlPoint2: CGPoint(x: 120.2, y: 50.2))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        return bezierPath.cgPath
    }
    
}


// MARK: Notifications
extension Notification.Name {
    static let notificationLocationChanged = Notification.Name("NotificationLocationChanged")
    static let notificationUserChanged = Notification.Name("NotificationUserChanged")
}

// MARK: Screen size
enum ScreenSize {
    static let isSmallScreen =  UIScreen.main.bounds.height <= 568 // iphone 4/5
    static let isMidScreen =  UIScreen.main.bounds.height <= 667 // iPhone 6 & 7
    static let isBigScreen =  UIScreen.main.bounds.height >= 736 // iphone 6Plus/7Plus
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
}


// MARK: media Type
enum AppMediaType :String{
    case video = "video/*"
    case image = "image/*"
    case audio = "audio/*"
}


// MARK: Application language
enum AppLanguage{
    case english
    case arabic
    
    var langCode:String {
        switch self {
        case .english:
            return "en"
        case .arabic:
            return "ar"
        }
    }
}
