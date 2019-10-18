//
//  FirebaseManager.swift
//  
//
//  Created by Molham Mahmoud on 23/07/18.
//  Copyright © 2018 BrainSocket. All rights reserved.
//

import SwiftyJSON
import Firebase
import FirebaseFunctions

/**This class handles all the comunications with the realtime database
 */
class FirebaseManager :NSObject {

    fileprivate var conversationRefHandle: DatabaseHandle?
    
    lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")
    lazy var functions = Functions.functions()
    
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    
    //MARK: Singelton
    public static var shared: FirebaseManager = FirebaseManager()
    
    private override init(){
        super.init()
        observeUnseenConversatins()
    }
    
    func createNewConversation (bottle: Bottle, completionBlock: @escaping (_ err: Error?, _ reference: DatabaseReference?) -> Void) {
        let newConvRef = self.conversationRef.childByAutoId()
        let conversationBlankDict = newConverastionDictionary(bottle: bottle)
        //print(conversationBlankDict)
        newConvRef.setValue(conversationBlankDict, withCompletionBlock: { (err, ref) in
            completionBlock(err, ref)
        })
    }
    
    func newConverastionDictionary(bottle: Bottle) -> [String : Any] {
        let convlItem:[String : Any] = [
            "bottle": bottle.dictionaryRepresentation(),
            "user": (DataStore.shared.me?.dictionaryRepresentation()) ?? "",
            "createdAt" : CUnsignedLongLong(DataStore.shared.currentUTCTime),
            "updatedAt" : CUnsignedLongLong(DataStore.shared.currentUTCTime),
            "is_seen" : 0,
            "is_replay_blocked": 0,
            "expired" : 0,
            "user1ID" : bottle.ownerId ?? "",
            "user2ID" : DataStore.shared.me?.objectId ?? "",
            "startTime" : 0.0,
            "finishTime": 0.0, 
            "user1_unseen": 1.0,
            "user2_unseen": 0.0,
            "user1LastSeenMessageId": "",
            "user2LastSeenMessageId": "",
            "user1ChatMute": false,
            "user2ChatMute": false
        ]
        return convlItem
    }
    
    func fetchMyBottlesConversations (completionBlock: @escaping (_ err: Error?) -> Void) {
        let childref = conversationRef
        childref.queryOrdered(byChild: "user1ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            
            DataStore.shared.myBottles = [Conversation]()
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                self.sortBottles(rest)
            }
            
            completionBlock(nil)
            
        }) { (err) in
            print(err.localizedDescription)
            completionBlock(err)
        }
    }
    
    func observeUnseenConversatins () {
        let childref = conversationRef
        childref.queryOrdered(byChild: "user2ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observe(.childChanged, with: { (snapshot) in
            // my replies
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            conversation.idString = snapshot.key
            
            if !conversation.isExpired {
                DataStore.shared.conversationsMyRepliesUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
                if !conversation.isConversationMuted {
                    DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
                }
            } else {
                DataStore.shared.conversationsMyRepliesUnseenMesssages[snapshot.key] = 0
                DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = 0
            }
            
//            // update the conversation last updateDate
//            if let index = DataStore.shared.myReplies.index(where: { (item) -> Bool in
//                item.idString == conversation.idString // test if this is the conversation we're looking for
//            }) {
//                let dataStoreConversation = DataStore.shared.myReplies[index]
//                dataStoreConversation.updatedAt = conversation.updatedAt
//                self.sortConversations()
//            }
            
            // broadcast
            NotificationCenter.default.post(name: Notification.Name("unreadMessagesChange"), object: nil)
        }) { (err) in
            print(err.localizedDescription)
        }
        
        //
        childref.queryOrdered(byChild: "user1ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observe(.childChanged, with: { (snapshot) in
            // my bottles
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            conversation.idString = snapshot.key
            
            if !conversation.isExpired {
                DataStore.shared.conversationsMyBottlesUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
                if !conversation.isConversationMuted {
                    DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
                }
            } else {
                DataStore.shared.conversationsMyBottlesUnseenMesssages[snapshot.key] = 0
                DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = 0
            }
            
//            // update the conversation last updateTime
//            if let index = DataStore.shared.myBottles.index(where: { (item) -> Bool in
//                item.idString == conversation.idString // test if this is the conversation we're looking for
//            }) {
//                let dataStoreConversation = DataStore.shared.myBottles[index]
//                dataStoreConversation.updatedAt = conversation.updatedAt
//                self.sortConversations()
//            }
            
            // broadcast
            NotificationCenter.default.post(name: Notification.Name("unreadMessagesChange"), object: nil)
        }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func fetchMyRepliesConversations (completionBlock: @escaping (_ err: Error?) -> Void) {
//        functions.httpsCallable("fetchReplies").call(["id" : DataStore.shared.me?.objectId ?? ""], completion: {result, error in
//            if let error = error as NSError? {
//                if error.domain == FunctionsErrorDomain {
//                    let code = FIRFunctionsErrorCode(rawValue: error.code)
//                    let message = error.localizedDescription
//                    let details = error.userInfo[FunctionsErrorDetailsKey]
//
//                    print(details)
//                }
//                // ...
//            }
//            if let text = (result?.data as? DataSnapshot){
//                print(text.children.allObjects)
//            }
//        })
        let childref = conversationRef
        childref.queryOrdered(byChild: "user2ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            
            DataStore.shared.myReplies = [Conversation]()
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                self.sortReplies(rest)
            }
            
            completionBlock(nil)
        }) { (err) in
            print(err.localizedDescription)
            completionBlock(err)
        }
    }
    
    func sortConversations () {
        // this will force the conversations to be sorted again
        DataStore.shared.allConversations = []
        
        
        // sort my replies
        
//
//        DataStore.shared.myReplies.sort(by: { (obj1, obj2) -> Bool in
//            if let date1 = obj1.updatedAt, let date2 = obj2.updatedAt {
//                return date1 > date2
//            }
//            return true
//        })
//
//        // sort my bottles
//        DataStore.shared.myBottles.sort(by: { (obj1, obj2) -> Bool in
//            if let date1 = obj1.updatedAt, let date2 = obj2.updatedAt {
//                return date1 > date2
//            }
//            return true
//        })
        
        //NotificationCenter.default.post(name: Notification.Name("unreadMessagesChange"), object: nil)
    }
    
    func sortReplies(_ snapshot: DataSnapshot) {
        let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
        conversation.idString = snapshot.key
        
        if !conversation.isExpired {
            DataStore.shared.myReplies.append(conversation)
            DataStore.shared.conversationsMyRepliesUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
            if !conversation.isConversationMuted {
                DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
            }
            
            ActionRegisterNotification.execute(conversation: conversation)
        } else {
            DataStore.shared.conversationsMyRepliesUnseenMesssages[snapshot.key] = 0
            DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = 0
        }
        
        
        //Last update sort
        DataStore.shared.myReplies.sort(by: { (obj1, obj2) -> Bool in
            if let date1 = obj1.updatedAt, let date2 = obj2.updatedAt {
                return date1 > date2
            }
            return true
        })
        
        // trigger data store set funnctions to cash the
        DataStore.shared.myReplies = DataStore.shared.myReplies
        
        // broadcast
        NotificationCenter.default.post(name: Notification.Name("unreadMessagesChange"), object: nil)
    }
    
    func sortBottles(_ snapshot: DataSnapshot) {
        let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
        conversation.idString = snapshot.key
        
        if !conversation.isExpired {
            DataStore.shared.myBottles.append(conversation)
            DataStore.shared.conversationsMyBottlesUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
            if !conversation.isConversationMuted {
                DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = conversation.myUnseenMessagesCount
            }
            
            ActionRegisterNotification.execute(conversation: conversation)
            
        } else {
            DataStore.shared.conversationsMyBottlesUnseenMesssages[snapshot.key] = 0
            DataStore.shared.conversationsUnmutedUnseenMesssages[snapshot.key] = 0
        }
        
        DataStore.shared.myBottles.sort(by: { (obj1, obj2) -> Bool in
            if let date1 = obj1.updatedAt, let date2 = obj2.updatedAt {
                return date1 > date2
            }
            return true
        })
        
        // trigger data store set funnctions to cash the
        DataStore.shared.myBottles = DataStore.shared.myBottles
        // broadcast
        NotificationCenter.default.post(name: Notification.Name("unreadMessagesChange"), object: nil)
    }
}





