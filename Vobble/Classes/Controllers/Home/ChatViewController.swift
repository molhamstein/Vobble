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
import NYTPhotoViewer
import SDRecordButton
import Flurry_iOS_SDK

final class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"
    
    var conversationRef: DatabaseReference?
    var conversationOriginalObject: Conversation?
    
    private lazy var messageRef: DatabaseReference = self.conversationRef!.child("messages")
//    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://vobble-1521577974841.appspot.com")
    //  private lazy var userIsTypingRef: DatabaseReference = self.conversationRef!.child("typingIndicator").child(self.senderId)
    //  private lazy var usersTypingQuery: DatabaseQuery = self.conversationRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    fileprivate var isLoadedMedia:Bool = true
    fileprivate var numberOfSentMedia = 0
    fileprivate var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQCustomPhotoMediaItem]()
    private var videoMessageMap = [String: JSQCustomVideoMediaItem]()
    private var audioMessageMap = [String: JSQAudioMediaItem]()
    
    @IBOutlet var customNavBar: VobbleChatNavigationBar!
    @IBOutlet var recordButton : SDRecordButton!
    @IBOutlet var lblRecording : UILabel!
    @IBOutlet var ivRecordingIcon : UIImageView!
    @IBOutlet var recordButtonContainer : UIView!
    
    // notifications
    var lastNotificationSentDate: Date?
    
    //  private var localTyping = false
    private var isInitialised = false
    
    var convTitle: String? {
        didSet {
            //      title = conversation?.user2?.firstName
            title = convTitle ?? ""
        }
    }
    
    var isHideInputToolBar: Bool = false
    
    var selectedImage: UIImage?
    var seconds: Double = 0.0
    
    // VobbleChatNavigationBar
    public var navUserName: String?
    public var navShoreName: String?
    
    var audioRec: AVAudioRecorder?
    var audioRecorder:AVAudioRecorder!
    var audioUrl: URL? = nil
    
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    var isAnimating: Bool = false
    var AudioFileName = "sound.m4a"
    var timeOut: Float = 0.0
    var recordTimer: Timer?
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
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
        if let userId = DataStore.shared.me?.objectId {
            self.senderId = "\(userId)"
        }
        customNavBar.delegate = self
        observeMessages()
        self.navigationItem.leftBarButtonItem = navBackButton
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.topContentAdditionalInset = 30
        
        if isHideInputToolBar {
            inputToolbar.isHidden = true
        } else {
            inputToolbar.isHidden = false
            initCustomToolBar()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialised == false {
            
            
            isInitialised = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if customNavBar.superview == nil {
            // re-add subiews connected from storyboard as the JSQM messages framewordk detaches them
            customNavBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110)
            self.view.addSubview(customNavBar)
            
            // init nav bar
//            customNavBar.title = convTitle ?? ""
            if seconds != 0.0 {
                customNavBar.timerLabel.startTimer(seconds: TimeInterval(seconds))
            } else {
                customNavBar.timerLabel.isHidden = true
                customNavBar.leftLabel.isHidden = true
            }
            customNavBar.shoreNameLabel.text = navShoreName
            customNavBar.userNameLabel.text = navUserName
            customNavBar.viewcontroller = self
            
            // record audio view
            lblRecording.font = AppFonts.bigBold
            lblRecording.text = "CHAT_RECORDING".localized
            self.recordButtonContainer.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.view.frame.height - self.inputToolbar.frame.height)
            self.recordButton.frame = CGRect(x: self.view.frame.width/2 - 60 , y: self.view.frame.height/2 - 10, width: 120, height: 120)
            self.ivRecordingIcon.frame = CGRect(x: 0 , y: 0, width: 50, height: 50)
            self.ivRecordingIcon.center = self.recordButton.center
            self.lblRecording.frame = CGRect(x: self.view.frame.width/2 - 100 , y: self.recordButton.frame.origin.y - 50, width: 200, height: 30)
            self.view.addSubview(self.recordButtonContainer)
            //            NSLayoutConstraint(item: recordButtonContainer, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: recordButtonContainer, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: recordButtonContainer, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: recordButtonContainer, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height - inputToolbar.frame.height).isActive = true
            
            self.recordButtonContainer.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
            //            recordButtonContainer.setNeedsLayout()
            //            recordButton.setNeedsLayout()
            //self.view.layoutIfNeeded()
            //            recordButtonContainer.layoutIfNeeded()
            //            recordButton.layoutIfNeeded()
            recordButtonContainer.isHidden = true
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
                    let photo: PreviewPhoto = PreviewPhoto(image: test, title: "")
                    let images = [photo]
                    let photosViewController = NYTPhotosViewController(photos: images)
                    present(photosViewController, animated: true, completion: nil)
                    
                }
            }
            // Video Message
            if mediaItem is JSQCustomVideoMediaItem {
                let videoItem = mediaItem as! JSQCustomVideoMediaItem
                print(videoItem.message.videoUrl)
                if  let videoUrl = videoItem.message.videoUrl, (videoUrl.hasPrefix("http://") || videoUrl.hasPrefix("https://")) {
                    
                    let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
                    previewControl.from = .chatView
                    previewControl.type = .VIDEO
                    previewControl.videoUrl = NSURL(string: videoUrl)!
                    
                    self.navigationController?.pushViewController(previewControl, animated: false)
                }
            }
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
                    mediaItem.message = message
                    self.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                }
                
            } else if let id = message.senderId, let mediaURL = message.audioUrl {
                
                let audioData = NSData(contentsOf: URL(string:mediaURL)!)
                let audioItem = JSQAudioMediaItem(data: audioData as Data?)
                self.addAudioMessage(withId: id, key: snapshot.key, mediaItem: audioItem)
               
                if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                    self.collectionView.reloadData()
                    self.videoMessageMap.removeValue(forKey: snapshot.key)
                }
                
            } else {
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
                    mediaItem.message = message
                    self.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: message.idString)
                }
                
            } else if let mediaURL = message.audioUrl {
                
                if let mediaItem = self.audioMessageMap[message.idString!] {
                    
                    let audioData = NSData(contentsOf: URL(string:mediaURL)!)
                    
                    mediaItem.audioData = audioData as Data?
                    self.collectionView.reloadData()
                    self.audioMessageMap.removeValue(forKey: message.idString!)
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
            "text": text!
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        onNewMessageSent()
        
        // 5
        finishSendingMessage()
        //    isTyping = false
    }
    
    func sendMediaMessage(mediaType: AppMediaType) -> String? {
        let itemRef = messageRef.childByAutoId()
        
        var messageItem = [
            "senderId": senderId!
            ]
        if mediaType == .video {
            messageItem["videoURL"] = imageURLNotSetKey
            messageItem["thumb"] = imageURLNotSetKey
        } else if mediaType == .image {
            messageItem["photoURL"] = imageURLNotSetKey
            messageItem["thumb"] = imageURLNotSetKey
        } else { // audio
            messageItem["audioURL"] = imageURLNotSetKey
        }
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        return itemRef.key
    }
    
    func setMediaURL(_ media: Media, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        if media.type == .image {
            itemRef.updateChildValues(["photoURL": media.fileUrl!])
        } else if media.type == .video {
            if let thumbUrl = media.thumbUrl {
                itemRef.updateChildValues(["thumb": thumbUrl, "videoURL": media.fileUrl!])
            } else {
                itemRef.updateChildValues(["videoURL": media.fileUrl!])
            }
        } else if media.type == .audio {
            itemRef.updateChildValues(["audioURL": media.fileUrl!])
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
    
    private func addAudioMessage(withId id: String, key: String, mediaItem: JSQAudioMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.audioData == nil ) {
                audioMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    func onNewMessageSent() {
        
        // send a push notifications to the peer if the last push notification sent was more than 20 seconds ago
        var shouldSenPushNotification = false
        if let lastNotifDate = lastNotificationSentDate {
            shouldSenPushNotification = ((lastNotifDate.timeIntervalSinceNow) >= 30)
        } else {
            shouldSenPushNotification = true
        }
        if shouldSenPushNotification {
            lastNotificationSentDate = Date()
            if let peer = conversationOriginalObject?.getPeer {
                let msgToSend = String(format: "NOTIFICATION_NEW_MSG".localized, (DataStore.shared.me?.userName)!)
                ApiManager.shared.sendPushNotification(msg: msgToSend, targetUser: peer, completionBlock: { (success, error) in })
            }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        if mediaType == "public.image" {
//            if let mediaReferenceUrl = info[UIImagePickerControllerImageURL] as? URL {
//                uploadPhoto(photoUrl: mediaReferenceUrl)
//            }else if let mediaReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
//                uploadPhoto(photoUrl: mediaReferenceUrl)
//            }

            if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                uploadPhoto(photo: photo)
            }
            
            if let asset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
                if let fileName = asset.value(forKey: "filename") as? String{
                    print(fileName)
                }
            }
            
        } else if mediaType == "public.movie" {
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                ActionCompressVideo.execute(inputURL: videoURL, outputURL: compressedURL) { (exportSession) in
                    guard let session = exportSession else {
                        return
                    }
                    // use the original video captured by the camera as the deault Video to upload
                    // and check if the compression successed then use the copressed video for upload
                    var videoUrlForUpload = videoURL;
                    
                    switch session.status {
                    case .completed:
                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                            return
                        }
                        print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                        videoUrlForUpload = compressedURL
                    default:
                        break
                    }
                    
                    DispatchQueue.main.async {
                        self.uploadVideo(videoUrl: videoUrlForUpload)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadPhoto(photo: UIImage) {
        if let key = sendMediaMessage(mediaType: .image) {
//            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoUrl], options: nil)
//            let asset = assets.firstObject
//            asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//                self.upload(url: (contentEditingInput?.fullSizeImageURL)!, key:key, mediaType: .image)
//            })
            self.upload(url: nil, photo:photo, key:key, mediaType: .image)
        }
    }
    
    func submitMessageWithVideoURL(videoUrl: String, thumbURL: String) {
        if let key = sendMediaMessage(mediaType: .video)  {
            let media:Media = Media()
            media.fileUrl = videoUrl
            media.thumbUrl = thumbURL
            media.type = .video
            self.setMediaURL(media, forPhotoMessageWithKey: key)
        }
    }
    
    func uploadVideo(videoUrl:URL) {
        if let key = sendMediaMessage(mediaType: .video)  {
            self.upload(url: videoUrl, photo: nil, key:key, mediaType: .video)
        }
    }
    
    func uploadAudio(audioUrl:URL) {
        if let key = sendMediaMessage(mediaType: .audio) {
            self.upload(url: audioUrl, photo: nil, key:key, mediaType: .audio)
        }
    }
    
    func upload(url:URL?, photo: UIImage?,  key:String, mediaType: AppMediaType) {
        
        self.isLoadedMedia = false
        self.numberOfSentMedia += 1
        
        let uploadCompletionBlock: (_ files: [Media], _ errorMessage: String?) -> Void = { (files, errorMessage) in
            
            if errorMessage == nil {
                self.numberOfSentMedia -= 1
                if self.numberOfSentMedia == 0 {
                    self.isLoadedMedia = true
                }
                self.setMediaURL(files[0], forPhotoMessageWithKey: key)
                
                self.onNewMessageSent()
                if self.messages.count <= 2 {
                    // this means this was the first reply messsage in the conversation and the chat is not open yet
                    // show explanation message
                    let alertController = UIAlertController(title: "", message: "CHAT_REPLY_SENT_MSG".localized, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                    Flurry.logEvent(AppConfig.reply_submitted);
                }
                
            } else {
                self.isLoadedMedia = true
                print("error")
            }
        }
        
        if let imageObject = photo, mediaType == .image {
            ApiManager.shared.uploadImage(imageData: imageObject, completionBlock: uploadCompletionBlock)
        } else if let mediaURL = url {
            let urls:[URL] = [mediaURL]
            ApiManager.shared.uploadMedia(urls: urls, mediaType: mediaType, completionBlock: uploadCompletionBlock)
        }
    }
}

// MARK:- ChatNavigationDelegate
extension ChatViewController: ChatNavigationDelegate {
    
    func navLeftBtnPressed() {
        if self.isLoadedMedia {
          dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "", message: "UPLOAD_MEDIA_WARNING".localized , preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(ok)
            let cancel = UIAlertAction(title: "cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//TODO: make custom chat toole bar class
// MARK:- AVAudioRecorderDelegate
extension ChatViewController: AVAudioRecorderDelegate {
    
    fileprivate func initCustomToolBar() {
        setupRecorder()
        let height: Float = Float(inputToolbar.contentView.leftBarButtonContainerView.frame.size.height)
        var image = UIImage(named: "chatMoreOptions")
        let mediaButton = UIButton(type: .custom)
        mediaButton.setImage(image, for: .normal)
        mediaButton.addTarget(self, action: #selector(self.showActionSheet), for: .touchUpInside)
        mediaButton.frame = CGRect(x: 0, y: 0, width: 25, height: CGFloat(height))
        
        image = UIImage(named: "recordSoundMsg")
        let recordButton = UIButton(type: .custom)
        recordButton.setImage(image, for: .normal)
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didPressRecordAudio(_:)))
        recordButton.addGestureRecognizer(longGestureRecognizer)
        recordButton.frame = CGRect(x: 30, y: 0, width: 25, height: CGFloat(height))
        inputToolbar.contentView.leftBarButtonItemWidth = 55
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(mediaButton)
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(recordButton)
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
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
    
    func camera() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.sourceType = .camera
        present(picker, animated: true, completion:nil)
    }
    
    func photoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.allowsEditing = false;
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image","public.movie"]
        present(picker, animated: true, completion:nil)
    }
    
    func didPressRecordAudio(_ sender: UILongPressGestureRecognizer){
        print("Long tap is handled")
        if sender.state == .began {
            //write the function for start recording the voice here
            
            // show record audio view
            recordButtonContainer.isHidden = false
            self.recordButtonContainer.alpha = 0.0
            self.recordButtonContainer.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 90)
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
                self.recordButtonContainer.transform = CGAffineTransform.identity
                self.recordButtonContainer.alpha = 1.0
            }, completion: {(finished: Bool) in })
            
            recordButton.setProgress(0.0)
            
            // reset the timer
            recordTimer?.invalidate()
            recordTimer = nil;
            // run the timer
            recordTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                               target: self,
                                               selector: #selector(RecordMediaViewController.tickRecorder(timer:)),
                                               userInfo: nil,
                                               repeats: true)
            
            // run the timer
            let runner: RunLoop = RunLoop.current
            runner.add(recordTimer!, forMode: .defaultRunLoopMode)
            
            soundRecorder.record()
        }
        else if sender.state == .ended {
            stopRecorderTimer()
            //write the function for stop recording the voice here
            if let url = audioUrl {
                  uploadAudio(audioUrl:url)
            }
        }
    }
    
    func setupRecorder(){
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    //set category and activate recorder session
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try self.soundRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: self.recordSettings)
                        self.soundRecorder.prepareToRecord()
                    } catch {
                        print("Error Recording");
                    }
                }
            })
        }
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        audioUrl = soundURL
        return soundURL
    }

    // Stop play image
    func tickRecorder(timer:Timer){
        // count down 0
        if (timeOut >= MAX_VIDEO_LENGTH){
            // stop image timer
            recordTimer?.invalidate()
            recordTimer = nil;
            stopRecorderTimer()
        } else {
            timeOut += 0.05;
//           recordTimeLabel.text = String(format: "%02d", Int(timeOut))
            self.recordButton.setProgress(CGFloat(timeOut/MAX_VIDEO_LENGTH))
        }
    }
    
    func stopRecorderTimer(){
        // stop recording
        self.recordButton.setProgress(0)
        timeOut = 0.0
        recordButtonContainer.isHidden = true
        soundRecorder.stop()
    }
}

// MARK:- class PreviewPhoto
class PreviewPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.gray])
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
    
    init(image: UIImage? = nil, title: String) {
        self.image = image
        self.imageData = nil
        self.attributedCaptionTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.gray])
        super.init()
    }
}
