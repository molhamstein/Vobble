//
//  Comment.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 7/10/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON

class Comment: BaseModel{
    // MARK: Keys
    private let kAuthor: String = "author"
    private let kCategories = "categories"
    private let kBody = "body"
    private let kMentions = "mentions"
    private let kAttachments = "attachments"
    private let kLikes = "likes"
    private let kReplies = "replies"
    private let kLikesCount = "likesCount"
    private let kRepliesCount = "repliesCount"
    private let kMedia = "media"
    private let kCreatedAt = "createdAt"
    private let kUpdatedAt = "updatedAt"
    
    
    // MARK: Properties
    public var author:AppUser?
    public var categories: [String]?
    public var body: String?
    public var mentions: [Mention]?
    public var attachments: [Attachment]?
    public var likes: [AppUser]?
    public var replies: [Reply]?
    public var likesCount: Int?
    public var repliesCount: Int?
    public var media: Attachment?
    private var createdString: String?
    private var updatedString: String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        if (json[kAuthor] != JSON.null) {
            author = AppUser(json: json[kAuthor])
        }
        categories = json[kCategories].map{$1.stringValue}
        body = json[kBody].string
        if let mentionsJsonArr = json[kMentions].array {
            mentions = mentionsJsonArr.map{Mention(json:$0)}
        }
        if let attachmentsJsonArr = json[kAttachments].array {
            attachments = attachmentsJsonArr.map{Attachment(json:$0)}
        }
        if let likesJsonArr = json[kLikes].array {
            likes = likesJsonArr.map{AppUser(json:$0)}
        }
        if let repliesJsonArr = json[kReplies].array {
            replies = repliesJsonArr.map{Reply(json:$0)}
        }
        if let count = json[kLikesCount].int {
            likesCount = count
        }
        if let count = json[kRepliesCount].int {
            repliesCount = count
        }
        if json[kMedia] != JSON.null {
            media = Attachment(json: json[kMedia])
        }
        createdString = json[kCreatedAt].string
        updatedString = json[kUpdatedAt].string
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        // author
        if let value = author {
            dictionary[kAuthor] = value.dictionaryRepresentation()
        }
        // categories
        if let value = categories {
            dictionary[kCategories] = value.map{$0}
        }
        // body
        if let value = body {
            dictionary[kBody] = value
        }
        // mentions
        if let array: [Mention] = mentions {
            let mentionsDictionaries : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
            dictionary[kMentions] = mentionsDictionaries
        }
        // attachments
        if let array: [Attachment] = attachments {
            let attachmentsDictionaries : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
            dictionary[kAttachments] = attachmentsDictionaries
        }
        // likes
        if let array: [AppUser] = likes {
            let likesDictionaries : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
            dictionary[kLikes] = likesDictionaries
        }
        // replies
        if let array: [Reply] = replies {
            let repliesDictionaries : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
            dictionary[kReplies] = repliesDictionaries
        }
        // likes count
        if let value = likesCount {
            dictionary[kLikesCount] = value
        }
        // replies count
        if let value = repliesCount {
            dictionary[kRepliesCount] = value
        }
        // media
        if let value = media {
            dictionary[kMedia] = value.dictionaryRepresentation()
        }
        // created at
        if let value = createdString {
            dictionary[kCreatedAt] = value
        }
        // updated at
        if let value = updatedString {
            dictionary[kUpdatedAt] = value
        }
        
        return dictionary
    }
}
