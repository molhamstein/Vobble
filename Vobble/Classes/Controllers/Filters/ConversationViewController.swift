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
import Photos

class ConversationViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var bottleCollectionView: UICollectionView!
    @IBOutlet weak var waveSubView: WaveView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    // empty placeholder
    @IBOutlet weak var emptyPlaceHolderView: UIView!
    @IBOutlet weak var emptyPlaceHolderLabel: UILabel!
    
//    fileprivate var currentUser: AppUser = AppUser()
    fileprivate var filteredConvArray: [Conversation] = [Conversation]()
    fileprivate var searchText: UITextField?
    fileprivate var searchString: String = ""
    public var tap: tapOption = .myBottles
    var imgLoading: UIActivityIndicatorView?
    var userImageView: UIImageView?
    
    
    // MARK: - firebase Properties
    fileprivate var conversationRefHandle: DatabaseHandle?
    
    fileprivate lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationView.viewcontroller = self
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationCollectionViewCellID")
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewHeader",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "conversationCollectionViewHeaderID")
        
        DataStore.shared.myBottles = [Conversation]()
        DataStore.shared.myReplies = [Conversation]()
        observeConversation()
        
        emptyPlaceHolderView.isHidden = true
        emptyPlaceHolderLabel.font = AppFonts.normal
        emptyPlaceHolderLabel.text = "MY_BOTTLES_EMPTY_PLACEHOLDER".localized
        
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
    
    override func customizeView() {
        super.customizeView()
        
        navigationView.title = "MY_BOTTLES_TITLE".localized
    }
    
    func refreshView () {
        if tap == .myBottles {
            if DataStore.shared.myBottles.count > 0 {
                self.emptyPlaceHolderView.isHidden = true
            } else {
                self.emptyPlaceHolderView.isHidden = false
            }
        } else {
            if DataStore.shared.myReplies.count > 0 {
                self.emptyPlaceHolderView.isHidden = true
            } else {
                self.emptyPlaceHolderView.isHidden = false
            }
        }
        self.bottleCollectionView.reloadData()
    }
    
}
// MARK: - UICollectionViewDataSource
extension ConversationViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filteredConvArray.count > 0 {
            // string contains non-whitespace characters
            return self.filteredConvArray.count
        } else if tap == .myBottles {
            return DataStore.shared.myBottles.count
        }
        
       return DataStore.shared.myReplies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let convCell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationCollectionViewCellID", for: indexPath) as! ConversationCollectionViewCell

        if self.filteredConvArray.count > 0 {
            let obj = self.filteredConvArray[indexPath.row]
            convCell.configCell(convObj: obj,tap: tap )
        } else if tap == .myBottles {
            let obj = (DataStore.shared.myBottles[indexPath.row])
            convCell.configCell(convObj: obj,tap: tap)
        } else if tap == .myReplies {
            let obj = (DataStore.shared.myReplies[indexPath.row])
            convCell.configCell(convObj: obj,tap: tap)
        }
        
        return convCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "conversationCollectionViewHeaderID", for: indexPath) as! ConversationCollectionViewHeader
        
        headerView.searchTetField.text = searchString
        headerView.searchTetField.delegate = self
        headerView.convVC = self
        headerView.awakeFromNib()
        self.searchText =  headerView.searchTetField
        self.userImageView = headerView.userImageView
        if let me = DataStore.shared.me {
            headerView.configCell(userObj: me)
        }
        
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
            conversation = DataStore.shared.myBottles[indexPath.row]
            
        } else if tap == .myReplies {
            conversation = DataStore.shared.myReplies[indexPath.row]
            
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
            
            let convRef = conversationRef.child(conversation.idString!)
            
            chatVc.senderDisplayName = "test"
            
            if tap == .myBottles {
                chatVc.convTitle = conversation.bottle?.owner?.userName ?? ""
                //if is_seen == false --> hide chat tool bar so we can't send any message
                chatVc.isHideInputToolBar = true
                
            } else if tap == .myReplies {
                chatVc.convTitle = conversation.user?.userName ?? ""
                if let is_seen = conversation.is_seen, is_seen == 0 {
                    convRef.updateChildValues(["is_seen": 1])
                    convRef.updateChildValues(["startTime": ServerValue.timestamp()])
                    chatVc.isHideInputToolBar = false
                    chatVc.seconds = 24.0*60.0*60.0
                  
                    // send push notification to peer to let him know that the chat is open now
                    let msgToSend = String(format: "NOTIFICATION_CHAT_IS_ACTIVE".localized, (DataStore.shared.me?.userName)!)
                    ApiManager.shared.sendPushNotification(msg: msgToSend, targetUser: conversation.getPeer!, completionBlock: { (success, error) in })
                 }
            }
//            chatVc.conversationRef = conversationRef.child("-L86Uca5m1JySQFqoqWP")
           
            if let is_seen = conversation.is_seen, is_seen == 1 {
                
                chatVc.isHideInputToolBar = false
                if let fTime = conversation.finishTime {
                    let currentDate = Date().timeIntervalSince1970 * 1000
                    chatVc.seconds = (fTime - currentDate)/1000.0
                }
            }
            
            if let userName = conversation.getPeer?.userName {
                chatVc.navUserName = userName
            }
            chatVc.conversationOriginalObject = conversation
            
            if let shore_id = conversation.bottle?.shoreId {
                for sh in  DataStore.shared.shores {
                    if sh.shore_id == shore_id {
                        chatVc.navShoreName = sh.name ?? ""
                        break
                    }
                }
            }
            chatVc.conversationRef = convRef
        }
    }
    
    func setUserImage() {
          showActionSheet()
    }
    
    func camera() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.sourceType = .camera
        present(picker, animated: true, completion:nil)
    }
    
    func photoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        present(picker, animated: true, completion:nil)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
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
            filteredConvArray = DataStore.shared.myBottles.filter{(($0.bottle?.owner?.userName)!.lowercased().contains(searchString.lowercased()))}
        } else if tap == .myReplies {
            filteredConvArray = DataStore.shared.myReplies.filter{(($0.user?.userName)!.lowercased().contains(searchString.lowercased()))}
        }
//        filteredConvArray = currentUser.conversationArray.filter{(($0.user2?.firstName)!.lowercased().contains(searchString.lowercased()))}
        
        print(filteredConvArray.count)
        
        bottleCollectionView.reloadData()
        
        return true
    }
}

extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImageView?.image = pickedImage
            
            self.imgLoading?.isHidden = false
            self.imgLoading?.hidesWhenStopped = true
            self.imgLoading?.activityIndicatorViewStyle = .gray
            self.imgLoading?.startAnimating()
            
            let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            ApiManager.shared.uploadImage(imageData: chosenImage) { (files, errorMessage) in
                
                if errorMessage == nil {
                    // update user object
                    var userCopy = DataStore.shared.me?.copy() as! AppUser
                    userCopy.profilePic = files[0].fileUrl
                    ApiManager.shared.updateUser(user: userCopy, completionBlock: { (success, error, newUser) in
                        self.imgLoading?.stopAnimating()
                        if error == nil {
                            DataStore.shared.me?.profilePic = files[0].fileUrl
                        } else {
                            
                        }
                    })
                    DataStore.shared.me?.profilePic = files[0].fileUrl
                    
                } else {
                    self.imgLoading?.stopAnimating()
                    print("error")
                }
            }
        }
    }
}

// MARK: Firebase related methods

extension ConversationViewController {
    
    fileprivate func observeConversation() {
        // We can use the observe method to listen for new
        // conversations being written to the Firebase DB
        
        self.navigationView.showProgressIndicator(show: true)
        conversationRef.observe(.childAdded, andPreviousSiblingKeyWith: { (snapshot, s) in
                
                self.navigationView.showProgressIndicator(show: false)
                let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
                conversation.idString = snapshot.key
                if let is_seen = conversation.is_seen, is_seen == 1 {
                    
                    if let startTime = conversation.startTime {
                        conversation.finishTime = startTime + (24*60*60*1000)
                    }
                } else {
                    conversation.isActive = false
                }
                
                if let is_active = conversation.isActive, !is_active {
                    //(My replies)
                    if let currentUserID = DataStore.shared.me?.objectId, let convUserID = conversation.user?.objectId,currentUserID == convUserID {
                        print("my bottles")
                        DataStore.shared.myBottles.append(conversation)
                        DataStore.shared.myBottles.sort(by: { (obj1, obj2) -> Bool in
                            return (obj1.createdAt! > obj2.createdAt!)
                        })
                        
                        self.refreshView()
                    } else if let currentUserID = DataStore.shared.me?.objectId,  let convBottleOwnerID = conversation.bottle?.owner?.objectId, currentUserID == convBottleOwnerID { // (My replies)
                        print("my replies")
                        DataStore.shared.myReplies.append(conversation)
                        DataStore.shared.myReplies.sort(by: { (obj1, obj2) -> Bool in
                            return (obj1.createdAt! > obj2.createdAt!)
                        })
                        self.refreshView()
                    }
                }
                
            }) { (error) in
                print("****************")
                print(error)
                self.navigationView.showProgressIndicator(show: false)
                self.emptyPlaceHolderView.isHidden = true
            }
        
        conversationRef.observe(.childChanged, with: { (snapshot) in
        
            self.navigationView.showProgressIndicator(show: false)
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            conversation.idString = snapshot.key
            if let is_seen = conversation.is_seen, is_seen == 1 {
                
                if let startTime = conversation.startTime {
                    conversation.finishTime = startTime + (24*60*60*1000)
                }
            } else {
                conversation.isActive = false
            }
            
            if let is_active = conversation.isActive, !is_active {
                //(My replies)
                if let currentUserID = DataStore.shared.me?.objectId, let convUserID = conversation.user?.objectId,currentUserID == convUserID {
                    
                    let myBottlesArray = DataStore.shared.myBottles
                    var i = 0
                    for conv in myBottlesArray {
                        if conv.idString == conversation.idString {
                            DataStore.shared.myBottles[i] = conversation
                            DataStore.shared.myBottles.sort(by: { (obj1, obj2) -> Bool in
                                return (obj1.createdAt! > obj2.createdAt!)
                            })
                            self.refreshView()
                            break
                        } else {
                            i = i + 1
                        }
                    }
                    
                } else if let currentUserID = DataStore.shared.me?.objectId,  let convBottleOwnerID = conversation.bottle?.owner?.objectId, currentUserID == convBottleOwnerID { // (My replies)
                    print("my replies")

                    let myBottlesArray = DataStore.shared.myReplies
                    var i = 0
                    for conv in myBottlesArray {
                        if conv.idString == conversation.idString {
                            DataStore.shared.myReplies[i] = conversation
                            DataStore.shared.myReplies.sort(by: { (obj1, obj2) -> Bool in
                                return (obj1.createdAt! > obj2.createdAt!)
                            })
                            self.refreshView()
                            break
                        } else {
                            i = i + 1
                        }
                    }
                }
            }
        })
    }
}
