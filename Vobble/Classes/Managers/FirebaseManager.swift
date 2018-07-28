//
//  FirebaseManager.swift
//  
//
//  Created by Molham Mahmoud on 23/07/18.
//  Copyright © 2018 BrainSocket. All rights reserved.
//

import SwiftyJSON
import Firebase

/**This class handles all the comunications with the realtime database
 */
class FirebaseManager :NSObject {

    fileprivate var conversationRefHandle: DatabaseHandle?
    
    lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")
    
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    
    //MARK: Singelton
    public static var shared: FirebaseManager = FirebaseManager()
    
    private override init(){
        super.init()
    }
    
    func createNewConversation (bottle: Bottle, completionBlock: @escaping (_ err: Error?, _ reference: DatabaseReference?) -> Void) {
        let newConvRef = self.conversationRef.childByAutoId()
        let conversationBlankDict = newConverastionDictionary(bottle: bottle)
        print(conversationBlankDict)
        newConvRef.setValue(conversationBlankDict) { (err, ref) in
            print("we are in block")
            completionBlock(err, ref)
        }
    }
    
    func newConverastionDictionary(bottle: Bottle) -> [String : Any] {
        let convlItem:[String : Any] = [
            "bottle": bottle.dictionaryRepresentation(),
            "user": (DataStore.shared.me?.dictionaryRepresentation()) ?? "",
            "createdAt" : ServerValue.timestamp(),
            "is_seen" : 0,
            "expired" : 0,
            "user1ID" : bottle.ownerId ?? "",
            "user2ID" : DataStore.shared.me?.objectId ?? "",
            "startTime" : 0.0
        ]
        return convlItem
    }
    
    func fetchMyBottlesConversations (completionBlock: @escaping (_ err: Error?) -> Void) {
        let childref = conversationRef
        childref.queryOrdered(byChild: "user1ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            DataStore.shared.myBottles = [Conversation]()
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                //this is 1 single message here
                let conversation = Conversation(json: JSON(rest.value as! Dictionary<String, AnyObject>))
                conversation.idString = rest.key
                
                if !conversation.isExpired {
                    DataStore.shared.myBottles.append(conversation)
                }
            }
            
            // show open chats first
            // if chat is not open yet sort them by date from newest to olders
            DataStore.shared.myBottles.sort(by: { (obj1, obj2) -> Bool in
                if obj1.is_seen! != obj2.is_seen! {
                    return (obj1.is_seen! >= 1)
                } else {
                    return (obj1.createdAt! > obj2.createdAt!)
                }
            })
            
            // trigger data store set funnctions to cash the
            DataStore.shared.myBottles = DataStore.shared.myBottles
            completionBlock(nil)
            
        }) { (err) in
            print(err.localizedDescription)
            completionBlock(err)
        }
    }
    
    func fetchMyRepliesConversations (completionBlock: @escaping (_ err: Error?) -> Void) {
        let childref = conversationRef
        childref.queryOrdered(byChild: "user2ID").queryEqual(toValue: DataStore.shared.me?.objectId ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            DataStore.shared.myReplies = [Conversation]()
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let conversation = Conversation(json: JSON(rest.value as! Dictionary<String, AnyObject>))
                conversation.idString = rest.key
                
                if !conversation.isExpired {
                    DataStore.shared.myReplies.append(conversation)
                }
            }
            
            // sort data to show on going conversations first
            DataStore.shared.myReplies.sort(by: { (obj1, obj2) -> Bool in
                if obj1.is_seen! != obj2.is_seen! {
                    return (obj1.is_seen! >= 1)
                } else {
                    return (obj1.createdAt! > obj2.createdAt!)
                }
            })
            
            // trigger data store set funnctions to cash the
            DataStore.shared.myReplies = DataStore.shared.myReplies
            completionBlock(nil)
        }) { (err) in
            print(err.localizedDescription)
            completionBlock(err)
        }
    }
}





