/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Photos
import Firebase
import JSQMessagesViewController
import SwiftyJSON

final class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"
    
    var conversationRef: DatabaseReference?
    
    private lazy var messageRef: DatabaseReference = self.conversationRef!.child("messages")
//    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://vobble-1521577974841.appspot.com")
    //  private lazy var userIsTypingRef: DatabaseReference = self.conversationRef!.child("typingIndicator").child(self.senderId)
    //  private lazy var usersTypingQuery: DatabaseQuery = self.conversationRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQCustomPhotoMediaItem]()
    private var videoMessageMap = [String: JSQCustomVideoMediaItem]()
    
    @IBOutlet var customNavBar: VobbleChatNavigationBar!
    
    //  private var localTyping = false
    
    var convTitle: String? {
        didSet {
            //      title = conversation?.user2?.firstName
            title = convTitle ?? ""
        }
    }
    
    var selectedImage: UIImage?
    var seconds = 0
    
    //  var isTyping: Bool {
    //    get {
    //      return localTyping
    //    }
    //    set {
    //      localTyping = newValue
    //      userIsTypingRef.setValue(newValue)
    //    }
    //  }
    
    /// Navigation bar custome back button
    var navBackButton : UIBarButtonItem  {
        let _navBackButton   = UIButton()
        _navBackButton.setBackgroundImage(UIImage(named: "navBackIcon"), for: .normal)
        _navBackButton.frame = CGRect(x: 0, y: 0, width: 20, height: 17)
        _navBackButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: _navBackButton)
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.senderId = FIRAuth.auth()?.currentUser?.uid
        if let userId = DataStore.shared.me?.id {
            self.senderId = "\(userId)"
        }
        observeMessages()
        self.navigationItem.leftBarButtonItem = navBackButton
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if customNavBar.superview == nil {
            // re-add subiews connected from storyboard as the JSQM messages framewordk detaches them
            customNavBar.frame = CGRect(x: 0, y: -20, width: self.view.frame.width, height: 110)
            self.view.addSubview(customNavBar)
            
            // init nav bar
//            customNavBar.title = convTitle ?? ""
            customNavBar.timerLabel.startTimer(seconds: TimeInterval(seconds))
            customNavBar.viewcontroller = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //    observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func backButtonAction(_ sender: AnyObject) {
        //        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let message = self.messages[indexPath.row]
        if message.isMediaMessage == true {
            let mediaItem = message.media
            // Photo Message
            if mediaItem is JSQCustomPhotoMediaItem {
                let photoItem = mediaItem as! JSQCustomPhotoMediaItem
                if let test: UIImage = photoItem.asyncImageView.image {
                    selectedImage = test
                    self.performSegue(withIdentifier: "showPhoto", sender: self)
                }
            }
            // Video Message
            if mediaItem is JSQCustomVideoMediaItem {
                let videoItem = mediaItem as! JSQCustomVideoMediaItem
                print(videoItem.message.videoUrl)
                if  let videoUrl = videoItem.message.videoUrl, videoUrl.hasPrefix("http://") {
                    
                    let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
                    previewControl.from = .chatView
                    previewControl.type = .VIDEO
                    previewControl.videoUrl = NSURL(string: videoUrl)!
                    
                    self.navigationController?.pushViewController(previewControl, animated: false)
                }
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            if let pageDeDestination = segue.destination as? ShowPhotoViewController {
                pageDeDestination.image = selectedImage!
            } else {
                print("type destination not ok")
            }
        } else {
            print("segue inexistant")
        }
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        messageRef = conversationRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
//            let messageData = snapshot.value as! Dictionary<String, String>
            
            let message = Message(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            message.idString = snapshot.key
            
            if let id = message.senderId, let name = message.senderName, let text = message.text, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else if let id = message.senderId, let mediaURL = message.photoUrl {
                
                let mediaItem = JSQCustomPhotoMediaItem(message: message, isOperator: id == self.senderId)
                self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                
                if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                    mediaItem.message = message
                    self.fetchImageDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                }
                
            } else if let id = message.senderId, let mediaURL = message.videoUrl {
                
                let mediaItem = JSQCustomVideoMediaItem(message: message, isOperator: id == self.senderId)
                self.addVideoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                
                if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                    mediaItem.message.videoUrl = mediaURL
                    self.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                }
                
            }  else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
       
            let message = Message(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            message.idString = snapshot.key
            
            if let mediaURL = message.photoUrl {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[message.idString!] {
                    mediaItem.message = message
                    self.fetchImageDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: message.idString)
                }
                
            } else if let mediaURL = message.videoUrl {
             
                if let mediaItem = self.videoMessageMap[message.idString!] {
                    mediaItem.message.videoUrl = mediaURL
                    self.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: message.idString)
                }
                
            }
        })
    }
    
    private func fetchImageDataAtURL(_ mediaURL: String, forMediaItem mediaItem: JSQCustomPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        mediaItem.setImageWithURL()
        self.collectionView.reloadData()
        guard key != nil else {
            return
        }
        self.photoMessageMap.removeValue(forKey: key!)
        
    }
    
    private func fetchVideoDataAtURL(_ mediaURL: String, forMediaItem mediaItem: JSQCustomVideoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        mediaItem.setThumbWithURL(url: URL(string: mediaURL)!)
        self.collectionView.reloadData()
        guard key != nil else {
            return
        }
        self.videoMessageMap.removeValue(forKey: key!)
        
    }
    
    //  private func observeTyping() {
    //    let typingIndicatorRef = conversationRef!.child("typingIndicator")
    //    userIsTypingRef = typingIndicatorRef.child(senderId)
    //    userIsTypingRef.onDisconnectRemoveValue()
    //    usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
    //
    //    usersTypingQuery.observe(.value) { (data: DataSnapshot) in
    //
    //      // You're the only typing, don't show the indicator
    //      if data.childrenCount == 1 && self.isTyping {
    //        return
    //      }
    //
    //      // Are there others typing?
    //      self.showTypingIndicator = data.childrenCount > 0
    //      self.scrollToBottom(animated: true)
    //    }
    //  }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "test": "test",
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        //    isTyping = false
    }
    
    func sendMediaMessage(mediaTag: String) -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            mediaTag : imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setMediaURL(_ media: Media, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        if media.type == "image/jpeg" ||  media.type == "image/png" {
            itemRef.updateChildValues(["photoURL": media.fileUrl!])
        } else if media.type == "video/quicktime" {
            itemRef.updateChildValues(["videoURL": media.fileUrl!])
        }
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//            return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: AppColors.blueXLight)
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.mediaTypes = ["public.image","public.movie"]
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQCustomPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func addVideoMessage(withId id: String, key: String, mediaItem: JSQCustomVideoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.thumbImageView.image == nil ) {
                videoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        //    isTyping = textView.text != ""
    }
    
    
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        if mediaType == "public.image" {
            if let mediaReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
                uploadPhoto(photoUrl: mediaReferenceUrl)
            }
            
        } else if mediaType == "public.movie" {
            if let mediaUrl = info[UIImagePickerControllerMediaURL] as? URL {
                uploadVideo(videoUrl: mediaUrl)
            }
        }
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadPhoto(photoUrl:URL) {
        
        if let key = sendMediaMessage(mediaTag: "photoURL") {
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoUrl], options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                
                self.upload(url: (contentEditingInput?.fullSizeImageURL)!, key:key)
            })
            
        }
    }
    
    func uploadVideo(videoUrl:URL) {
        
        if let key = sendMediaMessage(mediaTag: "videoURL")  {
             self.upload(url: videoUrl, key:key)
        }
    }
    
    func upload(url:URL,key:String) {
        
        let urls:[URL] = [url]
        ApiManager.shared.uploadMedia(urls: urls) { (files, errorMessage) in
            
            if errorMessage == nil {
               
                self.setMediaURL(files[0], forPhotoMessageWithKey: key)
                
            } else {
                print("error")
            }
            
        }
        
    }

    
//    func uploadMedia(mediaReferenceUrl:URL,mediaType: String,senderId:String) {
//        
////        let assets = PHAsset.fetchAssets(withALAssetURLs: [mediaReferenceUrl], options: nil)
////        let asset = assets.firstObject
//        
//        if let key = sendPhotoMessage() {
//            
////            let path = "\(senderId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(mediaReferenceUrl.lastPathComponent)"
//            
//            if mediaType  == "public.image" {
//                
////                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//                
////                    self.upload(url: (contentEditingInput?.fullSizeImageURL)!, path: path,key:key)
//                self.upload(url: mediaReferenceUrl, key:key)
//                
////                })
//                
//            } else if mediaType == "public.movie" {
//                
////                PHCachingImageManager().requestAVAsset(forVideo: asset!, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
////                    let asset = asset as! AVURLAsset
//                
////                    self.upload(url: asset.url, path: path,key:key)
//                 self.upload(url: mediaReferenceUrl, key:key)
////                })
//            }
//            
//        }
//    }
    
    
//    func upload(url:URL,path:String,key:String) {
//
//        self.storageRef.child(path).putFile(from: url, metadata: nil) { (metadata, error) in
//            if let error = error {
//                print("Error uploading media: \(error.localizedDescription)")
//                return
//            }
//            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
//        }
//        
//    }
}
