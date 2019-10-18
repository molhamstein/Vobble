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
    //static let appBaseDevURL = "http://104.217.253.15:7000/api"
    //static let appBaseDevURL = "http://192.168.1.7:3000/api"
    static let appBaseDevURL = "http://104.217.253.15:3034/api"
    //static let appBaseLiveURL = "http://159.65.202.38:3000/api"
    static let appBaseLiveURL = "http://chabani.tv:3000/api"
    static let useLiveAPI: Bool = true
    static let isProductionBuild: Bool = true
    static let useCurrentLocation: Bool = false
    static let contactUsEmail: String = "yallavideoapp@gmail.com"
    // used to give mails to users whoc dont have mails when login with facebook
    static let fakeMailsSuffix: String = "@vibo.com"
    
    // social
    static let instagramClienID = "99366a1b59984cffb7e99bb8c9c7fda8"
    static let instagramRedirectURI = "http://brain-socket.com"
    static let twitterConsumerKey = "eq0dVMoM1JqNcR6VJJILsdXNddo"
    static let twitterConsumerSecret = "6JkdvzSijm13xjBW0fYSEG4yF2tbro8pwxz1vDx290Bj0aMw2vssI"
    static let googleClientID = "82142364137-21s23clufpu4d0abp5ppa5na245tak1u.apps.googleusercontent.com"
//    static let oneSingleID = "3754a01e-b355-4248-a906-e04549e6ab32"
    static let oneSingleID = "e8a91e90-a766-4f1b-a47e-e3b3f569dbef"
    
    static let AppleStoreAppId = "id1407745068"
    
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
    static let filter_click_from_find_bottle = "Filter_Click_From_Find_Bottle"
    static let filter_pressed_go_gender = "Filter_go_to_gender"
    static let filter_pressed_go_country = "Filter_go_to_country"
    
    // Tut
    static let login_show = "login_show"
    static let login_success = "login_success"
    static let login_failure = "login_failure"
    static let signup_show = "signup_show"
    static let signup_submit = "signup_submit"
    static let signup_info_screen_show = "signup_info_screen_show"
    static let signup_info_screen_submit = "signup_info_screen_submit"
    
    // Tut
    static let tutorial_welcome_show = "Tutorial_Welcome_Show"
    static let tutorial_swipe_show = "Tutorial_Swipe_Show"
    static let tutorial_find_show = "Tutorial_Find_Show"
    static let tutorial_reply_show = "Tutorial_Reply_Show"
    /// Tut click
    static let tutorial_welcome_click = "Tutorial_Welcome_Click"
    static let tutorial_swipe_click = "Tutorial_Swipe_Click"
    static let tutorial_find_click = "Tutorial_Find_Click"
    static let tutorial_reply_click = "Tutorial_Reply_Click"
    
    // home
    static let home_press_sea = "Home_press_sea"
    
    //Login
    static let resend_code = "Resend_code_pressed"
    
    //Profile
    static let edit_username = "Edit_Username"
    
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
        bezierPath.move(to: CGPoint(x: 121.2, y: 39.9))
        bezierPath.addCurve(to: CGPoint(x: 117.5, y: 28.8), controlPoint1: CGPoint(x: 118.2, y: 37.7), controlPoint2: CGPoint(x: 117.5, y: 28.8))
        bezierPath.addLine(to: CGPoint(x: 117, y: 14.6))
        bezierPath.addLine(to: CGPoint(x: 117, y: 14.6))
        bezierPath.addLine(to: CGPoint(x: 117, y: 14.6))
        bezierPath.addLine(to: CGPoint(x: 117, y: 14.2))
        bezierPath.addCurve(to: CGPoint(x: 117.5, y: 13.2), controlPoint1: CGPoint(x: 117, y: 14.2), controlPoint2: CGPoint(x: 117.5, y: 14.1))
        bezierPath.addCurve(to: CGPoint(x: 116.7, y: 10.9), controlPoint1: CGPoint(x: 117.5, y: 12.1), controlPoint2: CGPoint(x: 117.7, y: 10.9))
        bezierPath.addCurve(to: CGPoint(x: 116.6, y: 9.3), controlPoint1: CGPoint(x: 116.6, y: 10.9), controlPoint2: CGPoint(x: 116.6, y: 9.3))
        bezierPath.addCurve(to: CGPoint(x: 116, y: 8.5), controlPoint1: CGPoint(x: 116.6, y: 8.8), controlPoint2: CGPoint(x: 116.3, y: 8.6))
        bezierPath.addLine(to: CGPoint(x: 116, y: 5.1))
        bezierPath.addLine(to: CGPoint(x: 116, y: 5.1))
        bezierPath.addLine(to: CGPoint(x: 116, y: 4.4))
        bezierPath.addLine(to: CGPoint(x: 116, y: 1.4))
        bezierPath.addCurve(to: CGPoint(x: 111.7, y: 0.2), controlPoint1: CGPoint(x: 116, y: 0.7), controlPoint2: CGPoint(x: 114, y: 0.2))
        bezierPath.addCurve(to: CGPoint(x: 107.3, y: 1.4), controlPoint1: CGPoint(x: 109.3, y: 0.2), controlPoint2: CGPoint(x: 107.3, y: 0.7))
        bezierPath.addLine(to: CGPoint(x: 107.3, y: 8.7))
        bezierPath.addCurve(to: CGPoint(x: 107, y: 9.3), controlPoint1: CGPoint(x: 107, y: 9), controlPoint2: CGPoint(x: 107, y: 9.3))
        bezierPath.addCurve(to: CGPoint(x: 107, y: 10.9), controlPoint1: CGPoint(x: 107, y: 9.3), controlPoint2: CGPoint(x: 107, y: 10.2))
        bezierPath.addCurve(to: CGPoint(x: 106.1, y: 11.5), controlPoint1: CGPoint(x: 106.2, y: 10.9), controlPoint2: CGPoint(x: 106.1, y: 11.5))
        bezierPath.addCurve(to: CGPoint(x: 106.1, y: 13.3), controlPoint1: CGPoint(x: 106.1, y: 11.5), controlPoint2: CGPoint(x: 106.1, y: 12.4))
        bezierPath.addCurve(to: CGPoint(x: 106.7, y: 14.4), controlPoint1: CGPoint(x: 106.1, y: 14.2), controlPoint2: CGPoint(x: 106.7, y: 14.4))
        bezierPath.addLine(to: CGPoint(x: 106.7, y: 14.4))
        bezierPath.addLine(to: CGPoint(x: 106.7, y: 14.8))
        bezierPath.addLine(to: CGPoint(x: 106.7, y: 14.8))
        bezierPath.addLine(to: CGPoint(x: 106.6, y: 28.9))
        bezierPath.addCurve(to: CGPoint(x: 102.6, y: 40), controlPoint1: CGPoint(x: 106.7, y: 36.1), controlPoint2: CGPoint(x: 104.5, y: 38.3))
        bezierPath.addCurve(to: CGPoint(x: 95.9, y: 51.4), controlPoint1: CGPoint(x: 97.5, y: 43.5), controlPoint2: CGPoint(x: 95.9, y: 51.4))
        bezierPath.addLine(to: CGPoint(x: 95.9, y: 117.8))
        bezierPath.addCurve(to: CGPoint(x: 111.1, y: 120), controlPoint1: CGPoint(x: 95.9, y: 117.8), controlPoint2: CGPoint(x: 99.4, y: 119.9))
        bezierPath.addCurve(to: CGPoint(x: 111.4, y: 120), controlPoint1: CGPoint(x: 111.3, y: 120), controlPoint2: CGPoint(x: 111.4, y: 120))
        bezierPath.addCurve(to: CGPoint(x: 111.6, y: 120), controlPoint1: CGPoint(x: 111.4, y: 120), controlPoint2: CGPoint(x: 111.4, y: 120))
        bezierPath.addCurve(to: CGPoint(x: 111.9, y: 120), controlPoint1: CGPoint(x: 111.7, y: 120), controlPoint2: CGPoint(x: 111.8, y: 120))
        bezierPath.addCurve(to: CGPoint(x: 128.1, y: 117.8), controlPoint1: CGPoint(x: 125.4, y: 120), controlPoint2: CGPoint(x: 128.1, y: 117.8))
        bezierPath.addCurve(to: CGPoint(x: 128.1, y: 51.4), controlPoint1: CGPoint(x: 128.1, y: 117.8), controlPoint2: CGPoint(x: 128.1, y: 56.8))
        bezierPath.addCurve(to: CGPoint(x: 121.2, y: 39.9), controlPoint1: CGPoint(x: 128.2, y: 45.9), controlPoint2: CGPoint(x: 125.4, y: 43))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        return bezierPath.cgPath
    }
    
    static func getDeviceId () -> String{
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        return deviceID
    }
    
    static func getBundleVersion () -> String{
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
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
