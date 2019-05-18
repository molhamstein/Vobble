//
//  User.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 6/12/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

// MARK: Gender types
enum GenderType: String {
    case male = "male"
    case female = "female"
    case allGender = "allGender"
}

enum Status: String {
    case pending = "pending"
    case active = "active"
    case deactivated = "deactivated"
}

// MARK: User login type
enum LoginType: String {
    case vobble = "registration"
    case facebook = "facebook"
    case twitter = "twitter"
    case google = "google"
    case instagram = "instegram"
    /// check current login state (Social - Normal)
    var isSocial:Bool {
        switch self {
        case .vobble:
            return false
        default:
            return true
        }
    }
}

class AppUser: BaseModel, NSCopying {
    // MARK: Keys
    private let kUserObjectIdKey = "id"
    private let kUserFirstNameKey = "username"
    private let kUserEmailKey = "email"
    private let kUserProfilePicKey = "image"
    private let kUserGenderKey = "gender"
    private let kUserCountryKey = "country"
    private let kUserCountryISOKey = "ISOCode"
    private let kUserLoginTypeKey = "typeLogIn"
    private let kUserStateKey = "status"
    private let kUserTokenKey = "token"
    private let kUserImage = "image"
    private let kUserBottles = "myBottles"
    private let kUserReplies = "myReplies"
    private let kUserSocialId = "socialId"
    private let kUserSocialToken = "token"
    private let kUserNextRefill = "nextRefill"
    private let kAccountInfoCompleted = "registrationCompleted"
    private let kFoundBottlesCount = "foundBottlesCount"
    private let kRepliesBottlesCount = "repliesBottlesCount"
    private let kPhoneNumber = "phonenumber"
    
    private let kHomeTutShowed = "homeTutShowed"
    private let kChatTutShowed = "ChatTutShowed"
    private let kReplyTutShowed = "tut3Showed"
    
    private let kUserBottlesCount = "totalBottlesThrown"
    private let kUserBottlesLeftToday = "bottlesCount"
    private let kUserExtraBottles = "extraBottlesCount"
    
    private let kBottleFirstColor: String = "fcolor"
    private let kBottleSecondColor: String = "lcolor"
    private let kBottleImageUrl: String = "imgurl"
    
    // MARK: Properties
    public var objectId: String?
    public var userName: String?
    public var email: String?
    public var profilePic: String?
    public var gender: GenderType?
    public var country: AppCountry?
    public var countryISOCode: String?
    public var loginType: LoginType?
    public var status: Status?
    public var token: String?
    public var foundBottlesCount: Int?
    public var repliesBottlesCount: Int?
    public var thrownBottlesCount: Int?
    public var bottlesLeftToThrowCount: Int?
    public var extraBottlesLeftToThrowCount: Int?
    public var accountInfoCompleted: Bool?
    public var phoneNumber: String?
    
    public var socialId: String?
    public var socialToken: String?
    public var nextRefillDate: Date?
    
    public var firstColor : UIColor?
    public var secondColor : UIColor?
    
    public var homeTutShowed : Bool?
    public var chatTutShowed : Bool?
    public var replyTutShowed : Bool?

    public var totalBottlesLeftToThrowCount: Int {
        get {
            if let bottlesLeft = bottlesLeftToThrowCount, let extraBottles = extraBottlesLeftToThrowCount {
                return bottlesLeft + extraBottles
            }
            return 0
        }
    }
    
    
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        objectId = json[kUserObjectIdKey].string
        userName = json[kUserFirstNameKey].string
        email = json[kUserEmailKey].string
        profilePic = json[kUserProfilePicKey].string
        
        if let genderString = json[kUserGenderKey].string {
            gender = GenderType(rawValue: genderString)
        }
        if json[kUserCountryKey] != JSON.null {
            country = AppCountry(json: json[kUserCountryKey])
        }
        countryISOCode = json[kUserCountryISOKey].string
        if let loginTypeString = json[kUserLoginTypeKey].string {
            loginType = LoginType(rawValue: loginTypeString)
        }
        if let accountStatus = json[kUserStateKey].string {
            status = Status(rawValue: accountStatus)
        }
        if let nextRefill = json[kUserNextRefill].string {
            nextRefillDate = DateHelper.getDateFromISOString(nextRefill)
        }
        
        if let value = json[kUserExtraBottles].int {
            extraBottlesLeftToThrowCount = value
        }
        
        if let value = json[kHomeTutShowed].bool {
            homeTutShowed = value
        }
        
        if let value = json[kChatTutShowed].bool {
            chatTutShowed = value
        }
        
        if let value = json[kReplyTutShowed].bool {
            replyTutShowed = value
        }
        
        if let value = json[kAccountInfoCompleted].bool {
            accountInfoCompleted = value
        }
        
        if let value = json[kPhoneNumber].string {
            phoneNumber = value
        }
        
        token = json[kUserTokenKey].string
        foundBottlesCount = json[kFoundBottlesCount].int
        thrownBottlesCount = json[kUserBottlesCount].int
        repliesBottlesCount = json[kRepliesBottlesCount].int
        bottlesLeftToThrowCount = json[kUserBottlesLeftToday].int
        
        socialId = json[kUserSocialId].string
        socialToken = json[kUserSocialToken].string
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        // object id
        if let value = objectId {
            dictionary[kUserObjectIdKey] = value
        }
        // first name
        if let value = userName {
            dictionary[kUserFirstNameKey] = value
        }
        // email
        if let value = email {
            dictionary[kUserEmailKey] = value
        }
        // phone number
        if let value = phoneNumber {
            dictionary[kPhoneNumber] = value
        }
        // profile picture
        if let value = profilePic {
            dictionary[kUserProfilePicKey] = value
        }
        // gender
        if let value = gender?.rawValue {
            dictionary[kUserGenderKey] = value
        }
        // country
        if let value = country {
            dictionary[kUserCountryKey] = value.dictionaryRepresentation()
        }
        if let value = countryISOCode {
            dictionary[kUserCountryISOKey] = value
        }
        // login type
        if let value = loginType?.rawValue {
            dictionary[kUserLoginTypeKey] = value
        }
        // account type
        if let value = status?.rawValue {
            dictionary[kUserStateKey] = value
        }
        // token
        if let value = token {
            dictionary[kUserTokenKey] = value
        }
        // found bottles count
        if let value = foundBottlesCount {
            dictionary[kFoundBottlesCount] = value
        }
        // bottle count
        if let value = repliesBottlesCount {
            dictionary[kRepliesBottlesCount] = value
        }
        if let value = thrownBottlesCount {
            dictionary[kUserBottlesCount] = value
        }
        // bottles left to throw count
        if let value = bottlesLeftToThrowCount {
            dictionary[kUserBottlesLeftToday] = value
        }
        
        if let value = extraBottlesLeftToThrowCount {
            dictionary[kUserExtraBottles] = value
        }
        
        if let value = socialToken {
            dictionary[kUserSocialToken] = value
        }
        if let value = socialId {
            dictionary[kUserSocialId] = value
        }
        if let value = nextRefillDate {
            dictionary[kUserNextRefill] = DateHelper.getISOStringFromDate(value)
        }
        
        // tutorials flags
        if let value = homeTutShowed {
            dictionary[kHomeTutShowed] = value
        }
        if let value = chatTutShowed {
            dictionary[kChatTutShowed] = value
        }
        if let value = replyTutShowed {
            dictionary[kReplyTutShowed] = value
        }
        
        if let value = accountInfoCompleted {
            dictionary[kAccountInfoCompleted] = value
        }
        
        //dictionary[kUserBottles] = myBottlesArray.map{$0}
        //dictionary[kUserReplies] = myRepliesArray.map{$0}
//        dictionary[kUserShopItems] = shopItems.map{$0}
        
        return dictionary
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AppUser()
        copy.objectId = objectId
        copy.userName = userName
        copy.email = email
        copy.phoneNumber = phoneNumber
        copy.profilePic = profilePic
        copy.gender = gender
        copy.countryISOCode = countryISOCode
        copy.loginType = loginType
        copy.status = status
        copy.token = token
        copy.foundBottlesCount = foundBottlesCount
        copy.thrownBottlesCount = thrownBottlesCount
        copy.repliesBottlesCount = repliesBottlesCount
        copy.bottlesLeftToThrowCount = bottlesLeftToThrowCount
        copy.extraBottlesLeftToThrowCount = extraBottlesLeftToThrowCount
        copy.socialId = socialId
        copy.socialToken = socialToken
        copy.nextRefillDate = nextRefillDate
        copy.homeTutShowed = homeTutShowed
        copy.chatTutShowed = chatTutShowed
        copy.replyTutShowed = replyTutShowed
        copy.accountInfoCompleted = accountInfoCompleted
        return copy
    }
}
