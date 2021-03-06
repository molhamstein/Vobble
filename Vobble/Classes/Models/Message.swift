//
//  Message.swift
//  Vobble
//
//  Created by Bayan on 4/3/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message: BaseModel {
    
    // MARK: Keys
    private let kSenderId: String = "senderId"
    private let kSenderName: String = "senderName"
    private let kText: String = "text"
    private let kIsSeen: String = "isSeen"
    private let kPhotoUrl: String = "photoURL"
    private let kVideoUrl: String = "videoURL"
    private let kAudioUrl: String = "audioURL"
    private let kThumb: String = "thumb"
    private let kAudioDuration: String = "duration"
    private let kIsGift: String = "isGift"
    
    // MARK: Properties
    public var idString : String?
    public var senderId : String?
    public var senderName : String?
    public var text : String?
    public var isSeen : Bool?
    public var photoUrl: String?
    public var videoUrl: String?
    public var audioUrl: String?
    public var thumbUrl: String?
    public var audioDuration: Double?
    public var isGift: Bool?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        
        if let value = json[kSenderId].string {
            senderId = value
        }
        if let value = json[kSenderName].string {
            senderName = value
        }
        if let value = json[kText].string {
            text = value
        }
        if let value = json[kPhotoUrl].string {
            photoUrl = value
        }
        if let value = json[kThumb].string {
            thumbUrl = value
        }
        if let value = json[kVideoUrl].string {
            videoUrl = value
        }
        if let value = json[kAudioUrl].string {
            audioUrl = value
        }
        if let value = json[kAudioDuration].double {
            audioDuration = value
        }
        if let value = json[kIsGift].bool {
            self.isGift = value
        }
        if let value = json[kIsSeen].bool {
            self.isSeen = value
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        
        if let value = senderId {
            dictionary[kSenderId] = value
        }
        if let value = senderName {
            dictionary[kSenderName] = value
        }
        if let value = text {
            dictionary[kText] = value
        }
        if let value = photoUrl {
            dictionary[kPhotoUrl] = value
        }
        if let value = thumbUrl {
            dictionary[kThumb] = value
        }
        if let value = videoUrl {
            dictionary[kVideoUrl] = value
        }
        if let value = audioUrl {
            dictionary[kAudioUrl] = value
        }
        if let value = audioDuration {
            dictionary[kAudioDuration] = value
        }
        if let value = isGift {
            dictionary[kIsGift] = value
        }
        if let value = isSeen {
            dictionary[kIsSeen] = value
        }
        
        return dictionary
    }
    
}
