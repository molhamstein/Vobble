//
//  ConversationViewController.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class ConversationViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var bottleCollectionView: UICollectionView!
    @IBOutlet weak var waveSubView: WaveView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
//    fileprivate var currentUser: AppUser = AppUser()
    fileprivate var filteredConvArray: [Conversation] = [Conversation]()
    fileprivate var searchText: UITextField?
    fileprivate var searchString: String = ""
    public var tap: tapOption = .myBottles
    
    // MARK: - firebase Properties
    fileprivate var conversationRefHandle: DatabaseHandle?
    
    fileprivate lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationView.viewcontroller = self
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationCollectionViewCellID")
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewHeader",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "conversationCollectionViewHeaderID")
        
        DataStore.shared.me?.myBottlesArray = [Conversation]()
        DataStore.shared.me?.myRepliesArray = [Conversation]()
        observeConversation()
        
    }
    
    deinit {
        if let refHandle = conversationRefHandle {
            conversationRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }
    
    
}
// MARK: - UICollectionViewDataSource
extension ConversationViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filteredConvArray.count > 0 {
            // string contains non-whitespace characters
            return self.filteredConvArray.count
        } else if tap == .myBottles {
            return DataStore.shared.me?.myBottlesArray.count ?? 0
        }
        
       return DataStore.shared.me?.myRepliesArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let convCell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationCollectionViewCellID", for: indexPath) as! ConversationCollectionViewCell

        if self.filteredConvArray.count > 0 {
            let obj = self.filteredConvArray[indexPath.row]
            convCell.configCell(convObj: obj,tap: tap )
        } else if tap == .myBottles {
            let obj = (DataStore.shared.me?.myBottlesArray[indexPath.row])!
            convCell.configCell(convObj: obj,tap: tap)
        } else if tap == .myReplies {
            let obj = (DataStore.shared.me?.myRepliesArray[indexPath.row])!
            convCell.configCell(convObj: obj,tap: tap)
        }
        
        return convCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "conversationCollectionViewHeaderID", for: indexPath) as! ConversationCollectionViewHeader
        
        headerView.searchTetField.text = searchString
        headerView.searchTetField.becomeFirstResponder()
        headerView.searchTetField.delegate = self
        headerView.convVC = self
        
        self.searchText =  headerView.searchTetField
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.bottleCollectionView.bounds.width, height: 230)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(155)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ConversationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var conversation = Conversation()
        
        if self.filteredConvArray.count > 0 {
            conversation = self.filteredConvArray[indexPath.row]
            
        } else if tap == .myBottles {
            conversation = (DataStore.shared.me?.myBottlesArray[indexPath.row])!
            
        } else if tap == .myReplies {
            conversation = (DataStore.shared.me?.myRepliesArray[indexPath.row])!
            
        }
        
        self.performSegue(withIdentifier: "goToChat", sender: conversation)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
           
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
            
            chatVc.senderDisplayName = "test"
            if tap == .myBottles {
                chatVc.convTitle = conversation.bottle?.owner?.firstName ?? ""
            } else if tap == .myReplies {
                chatVc.convTitle = conversation.user?.firstName ?? ""
            }
//            chatVc.conversationRef = conversationRef.child("-L86Uca5m1JySQFqoqWP")
            
            if let fTime = conversation.finishTime {
                let currentDate = Int(Date().timeIntervalSince1970 * 1000)
                chatVc.seconds = (Int(fTime) - currentDate)/1000
            }
            
            chatVc.conversationRef = conversationRef.child(conversation.idString!)
        }
    }
}

// MARK: - textfield delegate
extension ConversationViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string1 = string
        let string2 = (self.searchText?.text)!

        if string.characters.count > 0 { // if it was not delete character
            searchString = string2 + string1
        } else if string2.characters.count > 0 { // if it was a delete character
            
            searchString = String(string2.characters.dropLast())
        }
        
        if tap == .myBottles {
            filteredConvArray = (DataStore.shared.me?.myBottlesArray.filter{(($0.bottle?.owner?.firstName)!.lowercased().contains(searchString.lowercased()))})!
        } else if tap == .myReplies {
            filteredConvArray = (DataStore.shared.me?.myRepliesArray.filter{(($0.user?.firstName)!.lowercased().contains(searchString.lowercased()))})!
        }
//        filteredConvArray = currentUser.conversationArray.filter{(($0.user2?.firstName)!.lowercased().contains(searchString.lowercased()))}
        
        print(filteredConvArray.count)
        
        bottleCollectionView.reloadData()
        
        return true
    }
    
    
}

// MARK: Firebase related methods

extension ConversationViewController {
    
    fileprivate func observeConversation() {
        // We can use the observe method to listen for new
        // conversations being written to the Firebase DB
//        self.showActivityLoader(true)
//        conversationRefHandle = conversationRef.observe(.childAdded, with: { (snapshot) -> Void in
//
//            self.showActivityLoader(false)
//            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
//            conversation.idString = snapshot.key
//
//            //(My replies)
//            if DataStore.shared.me?.id == conversation.user?.objectId {
//                print("my bottles")
//                DataStore.shared.me?.myBottlesArray.append(conversation)
//                self.bottleCollectionView.reloadData()
//            } else if DataStore.shared.me?.id == conversation.bottle?.owner?.objectId { // (My replies)
//                print("my replies")
//                DataStore.shared.me?.myRepliesArray.append(conversation)
//                self.bottleCollectionView.reloadData()
//            }
//
//        })
        
        let convQuery = conversationRef.queryLimited(toLast:25)
        self.showActivityLoader(true)
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
//        conversationRefHandle = convQuery.observe(.childAdded, with: { (snapshot) -> Void in
//            self.showActivityLoader(false)
//            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
//            conversation.idString = snapshot.key
//            
//            //(My replies)
//            if DataStore.shared.me?.id == conversation.user?.objectId {
//                print("my bottles")
//                DataStore.shared.me?.myBottlesArray.append(conversation)
//                self.bottleCollectionView.reloadData()
//            } else if DataStore.shared.me?.id == conversation.bottle?.owner?.objectId { // (My replies)
//                print("my replies")
//                DataStore.shared.me?.myRepliesArray.append(conversation)
//                self.bottleCollectionView.reloadData()
//            }
//        })
        
        conversationRef.observe(.childAdded, andPreviousSiblingKeyWith: { (snapshot, s) in
            
            self.showActivityLoader(false)
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            conversation.idString = snapshot.key
            if let created_at = conversation.createdAt {
                conversation.finishTime = created_at + (24*60*60*1000)
            }
            
            //(My replies)
            if DataStore.shared.me?.id == conversation.user?.objectId {
                print("my bottles")
                DataStore.shared.me?.myBottlesArray.append(conversation)
                self.bottleCollectionView.reloadData()
            } else if DataStore.shared.me?.id == conversation.bottle?.owner?.objectId { // (My replies)
                print("my replies")
                DataStore.shared.me?.myRepliesArray.append(conversation)
                self.bottleCollectionView.reloadData()
            }
            
        }) { (error) in
            self.showActivityLoader(false)
        }
//        self.showActivityLoader(false)
        
    }
}
