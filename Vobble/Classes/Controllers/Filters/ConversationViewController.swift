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
    var imgLoading: UIActivityIndicatorView?
    var userImageView: UIImageView?
    
    
    // MARK: - firebase Properties
//    fileprivate var conversationRefHandle: DatabaseHandle?
//
//    fileprivate lazy var conversationRef: DatabaseReference = Database.database().reference().child("conversations")
//
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationView.viewcontroller = self
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationCollectionViewCellID")
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewHeader",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "conversationCollectionViewHeaderID")
        
        DataStore.shared.myBottles = [Conversation]()
        DataStore.shared.myReplies = [Conversation]()
        
        observeConversation()
        self.refreshView()
        
        emptyPlaceHolderView.isHidden = true
        emptyPlaceHolderLabel.font = AppFonts.normal
        emptyPlaceHolderLabel.text = "MY_BOTTLES_EMPTY_PLACEHOLDER".localized
        
    }
    
    deinit {
        
    }
    
    func releaseFirebaseReferences(){
        
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
        if let convs = DataStore.shared.allConversations, convs.count > 0 {
            self.emptyPlaceHolderView.isHidden = true
        } else {
            self.emptyPlaceHolderView.isHidden = false
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
        } else if let convs = DataStore.shared.allConversations {
            return convs.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let convCell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationCollectionViewCellID", for: indexPath) as! ConversationCollectionViewCell

        if self.filteredConvArray.count > 0 {
            let obj = self.filteredConvArray[indexPath.row]
            convCell.configCell(convObj: obj)
        } else if let convs = DataStore.shared.allConversations, convs.count > indexPath.row {
            let obj = convs[indexPath.row]
            convCell.configCell(convObj: obj)
        }
        
        return convCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "conversationCollectionViewHeaderID", for: indexPath) as! ConversationCollectionViewHeader
        
//        headerView.searchTetField.text = searchString
//        headerView.searchTetField.delegate = self
//        headerView.searchTetField.addTarget(self, action:#selector(onSearchTextFieldChanged(_:)), for: .editingChanged)
        headerView.convVC = self
        //headerView.awakeFromNib()
//        self.searchText =  headerView.searchTetField
        self.userImageView = headerView.userImageView
        if let me = DataStore.shared.me {
            headerView.configCell(userObj: me)
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.bottleCollectionView.bounds.width, height: 130)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(125)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ConversationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var conversation = Conversation()
        
        if self.filteredConvArray.count > 0 {
            conversation = self.filteredConvArray[indexPath.row]
            
        } else if let convs = DataStore.shared.allConversations, convs.count > indexPath.row {
            conversation = convs[indexPath.row]
        }
        
        //self.performSegue(withIdentifier: "goToChat", sender: conversation)
        if let chatID = conversation.idString {
            ActionOpenChat.execute(chatId: chatID, conversation: nil, inNavigationController: self.navigationController)
        }
        
        //assert(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let conversation = sender as? Conversation {
           
            let nav = segue.destination as! UINavigationController
            let chatVc = nav.topViewController as! ChatViewController
            //chatVc.conversationOriginalObject = conversation
            chatVc.conversationId = conversation.idString
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
        
        actionSheet.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery".localized, style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
}

// MARK: - textfield delegate
extension ConversationViewController {
    
    func onSearchTextFieldChanged(_ textField: UITextField) -> Bool {
//        let string1 = string
//        let string2 = (self.searchText?.text)!
//
//        if string.characters.count > 0 { // if it was not delete character
//            searchString = string2 + string1
//        } else if string2.characters.count > 0 { // if it was a delete character
//
//            searchString = String(string2.characters.dropLast())
//        }
        
        if let str = textField.text {
            searchString = str
            if let convs = DataStore.shared.allConversations {
                filteredConvArray = convs.filter{(($0.bottle?.owner?.userName)!.lowercased().contains(searchString.lowercased()))}
            }
        } else {
            searchString = ""
            if let convs = DataStore.shared.allConversations {
                filteredConvArray = convs
            }
        }
        // make sure we only update the items not the header so we dont loose the text field
//        var itemCountToUpdate = self.collectionView(bottleCollectionView, numberOfItemsInSection: 0)
//        var itemsIndexesToUpdate = [IndexPath]()
//        for i in 0..<itemCountToUpdate {
//            itemsIndexesToUpdate.append(IndexPath(index:i))
//        }
        //itemsIndexesToUpdate.append(IndexPath(index:1))
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
        
        FirebaseManager.shared.fetchMyBottlesConversations { (err) in
            self.navigationView.showProgressIndicator(show: false)
            if let error = err {
                print(error.localizedDescription)
            } else {
                self.refreshView()
            }
        }
        
        FirebaseManager.shared.fetchMyRepliesConversations { (err) in
            self.navigationView.showProgressIndicator(show: false)
            if let error = err {
                print(error.localizedDescription)
            } else {
                self.refreshView()
            }
        }
        
        FirebaseManager.shared.conversationRef.observe(.childChanged, with: { (snapshot) in
            
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            conversation.idString = snapshot.key
            
            if !conversation.isExpired {
                //(My replies)
                if let currentUserID = DataStore.shared.me?.objectId, let convUserID = conversation.user?.objectId,currentUserID == convUserID {
                    
                    //print("my replies")
                    let myBottlesArray = DataStore.shared.myReplies
                    var i = 0
                    for conv in myBottlesArray {
                        if conv.idString == conversation.idString {
                            DataStore.shared.myReplies[i] = conversation
                            FirebaseManager.shared.sortConversations()
                            self.refreshView()
                            break
                        } else {
                            i = i + 1
                        }
                    }
                    
                } else if let currentUserID = DataStore.shared.me?.objectId,  let convBottleOwnerID = conversation.bottle?.owner?.objectId, currentUserID == convBottleOwnerID {
                    // (My bottles)
                    let myBottlesArray = DataStore.shared.myBottles
                    var i = 0
                    for conv in myBottlesArray {
                        if conv.idString == conversation.idString {
                            DataStore.shared.myBottles[i] = conversation
                            FirebaseManager.shared.sortConversations()
                            self.refreshView()
                            break
                        } else {
                            i = i + 1
                        }
                    }
                }
            }
            //self.navigationView.showProgressIndicator(show: false)
        })
    }
}
