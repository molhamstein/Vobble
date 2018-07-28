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
    static let appBaseLiveURL = "https://brain-socket.com/live"
    static let useLiveAPI: Bool = false
    static let useCurrentLocation: Bool = false
    static let contactUsEmail: String = "hey@vobble.com"
    
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
