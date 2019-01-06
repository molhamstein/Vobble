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
import SDWebImage
import AVFoundation
import FillableLoaders

final class ChatViewController: JSQMessagesViewController, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"
    
    var conversationRef: DatabaseReference?
    var conversationOriginalObject: Conversation?
    
    // passed by deeplinking
    var conversationId: String?
    
    private lazy var firstReplyRef: DatabaseReference = self.conversationRef!.child("is_seen")
    private lazy var messageRef: DatabaseReference = self.conversationRef!.child("messages")
    private var unseenCountRef: DatabaseReference?
    private var lastSeenMessageRef: DatabaseReference?
    private lazy var userIsTypingRef: DatabaseReference = self.conversationRef!.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery = self.conversationRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    private var unseenMessagesCountRefHandle: DatabaseHandle?
    private var updateLastSeenMessageRefHandle: DatabaseHandle?
    private var updateFirstReplyRefHandle: DatabaseHandle?
    private var updateMuteChatRefHandle: DatabaseHandle?
    
    fileprivate var isLoadedMedia:Bool = true
    fileprivate var numberOfSentMedia = 0
    fileprivate var messages: [JSQMessage] = []
    private var messagesWithId: [String] = []
    private var photoMessageMap = [String: JSQCustomPhotoMediaItem]()
    private var videoMessageMap = [String: JSQCustomVideoMediaItem]()
    private var audioMessageMap = [String: JSQCustomAudioMediaItem]()
    var retryUploadAttemptsLeft = 2
    private var isChatBlockedShowedBefore = false // used to make sure we show the chat blocked screen only once
    
    fileprivate var isRTL:Bool = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    
    @IBOutlet var customNavBar: VobbleChatNavigationBar!
    @IBOutlet var recordButton : SDRecordButton!
    @IBOutlet var lblRecording : UILabel!
    @IBOutlet var lblTimerRecording : UILabel!
    @IBOutlet var ivRecordingIcon : UIImageView!
    @IBOutlet var recordButtonContainer : UIView!
    
    @IBOutlet var chatBlockedContainer : UIView!
    @IBOutlet var chatBlockedLabel : UILabel!
    
    @IBOutlet var chatPendingContainer : UIView!
    @IBOutlet var chatPendingLabel : UILabel!
    @IBOutlet var chatPendingImageView : UIImageView!
    @IBOutlet var chatPendingCloseButton : UIButton!
    
    var videoUploadLoader: WavesLoader?
    
    // notifications
    var lastNotificationSentDate: Date?
    
    private var localTyping = false
    private var isInitialised = false
    
    var convTitle: String? {
        didSet {
            //      title = conversation?.user2?.firstName
            title = convTitle ?? ""
        }
    }
    
    var selectedImage: UIImage?
    var seconds: Double = 0.0
    
    // VobbleChatNavigationBar
    public var navUserName: String?
    public var navShoreName: String?
    
    var audioUrl: URL? = nil
    
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    var isAnimating: Bool = false
    //var AudioFileName = "sound.m4a"
    var timeOut: Float = 0.0
    var recordTimer: Timer?
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    var replyVideoUrlToUpload: URL?
    var bottleToReplyTo: Bottle?
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
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
    
    /// isSeen
    var lastSeenMessageId : String = "0"
    var messageCounter: Int = 0
    var seenStr: NSAttributedString?
    
    /// Record beep
    var beepSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "audio_msg_beeb", ofType: "mp3")!)
    var beepPlayer = AVAudioPlayer()
    
    /// Audio messages
    var currentAudioIndex: Int!
    
    var isUserMuted = false
    var muteImg = #imageLiteral(resourceName: "speakerMuted2")
    var unmuteImg = #imageLiteral(resourceName: "speaker")
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.senderId = FIRAuth.auth()?.currentUser?.uid
        
        if let userId = DataStore.shared.me?.objectId {
            self.senderId = "\(userId)"
            self.senderDisplayName = ""
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        customNavBar.delegate = self
        
        if let conv = conversationOriginalObject {
            initWithConversation(conversation: conv)
            observeMessages()
            observeFirstReply()
            observeMuteAction()
        } else if let convId = conversationId {
            if let _ = bottleToReplyTo {
                // this is the first reply on a bottle
                initNewConversation()
            }
            fetchConversationByid(convId: convId)
        }
        
        self.navigationItem.leftBarButtonItem = navBackButton
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.topContentAdditionalInset = 55
        
        // dismiss keyboard on press
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.collectionView.addGestureRecognizer(tapGesture)
        
        // Register new audio cells
        super.collectionView.register(UINib(nibName: "AudioCollectionViewCellOutgoing", bundle: nil), forCellWithReuseIdentifier: "AudioCollectionViewCellOutgoing_id")
        super.collectionView.register(UINib(nibName: "AudioCollectionViewCellIncoming", bundle: nil), forCellWithReuseIdentifier: "AudioCollectionViewCellIncoming_id")
        
        // Setup Attribute for seen bottom label
        let paragraphStyle = NSMutableParagraphStyle()
        if isRTL {
            paragraphStyle.alignment = .left
        } else {
            paragraphStyle.alignment = .right
        }
        paragraphStyle.firstLineHeadIndent = 5.0
        
        let attributes: [String: Any] = [
            NSForegroundColorAttributeName: AppColors.blueXLight,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        seenStr = NSAttributedString(string: "SEEN".localized, attributes: attributes)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialised == false {
            
            if customNavBar.superview == nil {
                // init nav bar
                initNavBar()
                
                // re-add subiews connected from storyboard as the JSQM messages framewordk detaches them
                customNavBar.frame = CGRect(x: 0, y: -10, width: UIScreen.main.bounds.width, height: 110)
                self.view.addSubview(customNavBar)
                
                // record audio view
                lblRecording.font = AppFonts.bigBold
                lblRecording.text = "CHAT_RECORDING".localized
                lblTimerRecording.font = AppFonts.bigBold
                lblTimerRecording.textAlignment = .center
                
                var safeAreaHeight :CGFloat = 0.0
                if #available(iOS 11.0, *) {
                    if let window = UIApplication.shared.keyWindow {
                        safeAreaHeight = window.safeAreaInsets.bottom
                    }
                }
                var recordTimerXPos = isRTL ? 80 : UIScreen.main.bounds.width - 80 - 50
                var recordButtonXPos = isRTL ? 20 : UIScreen.main.bounds.width - 40 - 20
                
                self.recordButtonContainer.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - safeAreaHeight, width: UIScreen.main.bounds.width, height: (inputToolbar.frame.size.height + safeAreaHeight) )
                self.recordButton.frame = CGRect(x: recordButtonXPos , y: 2, width: 40, height: 40)
                self.ivRecordingIcon.frame = CGRect(x: 0 , y: 0, width: 20, height: 20)
                self.ivRecordingIcon.center = self.recordButton.center
                self.lblRecording.frame = CGRect(x: self.view.frame.width/2 - 75 , y: self.recordButton.frame.origin.y + 5, width: 150, height: 30)
                self.lblTimerRecording.frame = CGRect(x: recordTimerXPos , y: self.recordButton.frame.origin.y + 5, width: 50, height: 30)
                self.view.addSubview(self.recordButtonContainer)
                
                self.recordButtonContainer.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .diagonal)
                recordButtonContainer.isHidden = true
                
                // chat blocked view
                self.chatBlockedContainer.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width, height: 50)
                self.chatBlockedLabel.frame = CGRect(x: 20 , y: 5, width: UIScreen.main.bounds.width - 40, height: 40)
                chatBlockedLabel.font = AppFonts.normal
                chatBlockedLabel.text = "CHAT_BLOCKED".localized
                self.view.addSubview(self.chatBlockedContainer)
                //self.chatBlockedContainer.isHidden = true
                
                // chat pending view
                self.chatPendingContainer.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.chatBlockedContainer.frame.height)
                self.chatPendingLabel.frame = CGRect(x: 20 , y: 160, width: UIScreen.main.bounds.width - 40, height: 80)
                self.chatPendingImageView.frame = CGRect(x: 25 , y: 300, width: UIScreen.main.bounds.width - 50, height: self.chatPendingContainer.frame.height - 400)
                self.chatPendingCloseButton.frame = CGRect(x: UIScreen.main.bounds.width - 45 , y: 45, width: 35, height: 35)
                chatPendingLabel.font = AppFonts.normalBold
                chatPendingLabel.text = "CHAT_REPLY_SENT_MSG".localized
                //self.chatPendingContainer.isHidden = true
                self.view.addSubview(self.chatPendingContainer)
                
                // chat background
                let bgImage = UIImageView()
                bgImage.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                bgImage.image = UIImage(named: "chat_bg")
                bgImage.contentMode = .scaleAspectFill
                bgImage.backgroundColor = UIColor(red:242/255, green:234/255, blue:220/255, alpha:0.0)
                self.collectionView.backgroundColor = UIColor.clear
                self.view.insertSubview(bgImage, belowSubview: self.collectionView)
                
                // upload the reply video here to make sure we can show the loader
                if let replyVideoUrl = replyVideoUrlToUpload {
                    self.uploadVideo(videoUrl: replyVideoUrl)
                }
                setupRecorder()
                //chatPendingContainer.isHidden = true
            }
            isInitialised = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeTyping()
        
    }
    
    deinit {
        disposeFirebaseReference()
    }
    
    func disposeFirebaseReference() {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = unseenMessagesCountRefHandle {
            unseenCountRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updateLastSeenMessageRefHandle {
            lastSeenMessageRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updateFirstReplyRefHandle {
            firstReplyRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updateMuteChatRefHandle {
            conversationRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let alertController = UIAlertController(title: "MemoryWarning", message: "Memory Warning recieved", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func initNavBar() {
//        customNavBar.title = convTitle ?? ""
        customNavBar.leftLabel.text = "CHAT_NAV_TIME_LEFT".localized
        if seconds != 0.0 {
            customNavBar.timerLabel.startTimer(seconds: TimeInterval(seconds))
        } else {
            customNavBar.timerLabel.isHidden = true
            customNavBar.leftLabel.isHidden = true
        }
        customNavBar.shoreNameLabel.text = navShoreName
        customNavBar.userNameLabel.text = navUserName
        if let peerPicString = conversationOriginalObject?.getPeer?.profilePic, let picUrl = URL(string:peerPicString), picUrl.isValidUrl(){
            customNavBar.userImageView.sd_setImage(with: picUrl)
        }
        customNavBar.userImageButton.addTarget(self, action: #selector(self.didTapPeerImage(_:)), for: .touchUpInside)
        customNavBar.viewcontroller = self
    }
    
    // init
    // this method is required
    func initWithConversation (conversation: Conversation) {
        let chatVc = self
        
        if chatVc.conversationRef == nil {
            chatVc.conversationRef = FirebaseManager.shared.conversationRef.child(conversation.idString ?? "")
        }
        
        chatVc.senderDisplayName = DataStore.shared.me?.userName ?? ""
        
        if conversation.isMyBottle {
            chatVc.convTitle = conversation.bottle?.owner?.userName ?? ""
            
            if let is_seen = conversation.is_seen, is_seen == 0 {
                chatVc.conversationRef?.updateChildValues(["is_seen": 1])
                chatVc.conversationRef?.updateChildValues(["startTime": ServerValue.timestamp()])
                chatVc.seconds = 24.0*60.0*60.0
                
                // send push notification to peer to let him know that the chat is open now
                let msgToSend = String(format: "NOTIFICATION_CHAT_IS_ACTIVE".localized, (DataStore.shared.me?.userName)!)
                let msgToSendAr = String(format: "NOTIFICATION_CHAT_IS_ACTIVE_AR".localized, (DataStore.shared.me?.userName)!)
                ApiManager.shared.sendPushNotification(msg: msgToSend, msg_ar: msgToSendAr, targetUser: conversation.getPeer!, chatId: self.conversationId, completionBlock: { (success, error) in })
                
                // schedule a notification to remind the users before the chat expires
                ApiManager.shared.onReplyOpened(conversation: conversation, completionBlock: { (success, err) in})
            }
            
            if conversation.user2ChatMute ?? false{
                self.customNavBar.moreOptions.setImage(self.muteImg, for: .normal)
            }else {
                self.customNavBar.moreOptions.setImage(self.unmuteImg, for: .normal)
            }
            
        } else {
            
            if conversation.user1ChatMute ?? false {
                self.customNavBar.moreOptions.setImage(self.muteImg, for: .normal)
            }else {
                self.customNavBar.moreOptions.setImage(self.unmuteImg, for: .normal)
            }
            
            chatVc.convTitle = conversation.user?.userName ?? ""
        }
        
        if let is_seen = conversation.is_seen, is_seen == 1 {
            
            if let fTime = conversation.finishTime {
                let currentDate = Date().timeIntervalSince1970 * 1000
                chatVc.seconds = (fTime - currentDate)/1000.0
            }
        }
        
        if let userName = conversation.getPeer?.userName {
            chatVc.navUserName = userName
        }
        
        if let shore_id = conversation.bottle?.shoreId {
            for sh in  DataStore.shared.shores {
                if sh.shore_id == shore_id {
                    chatVc.navShoreName = sh.name ?? ""
                    break
                }
            }
        }
        
        //if is_seen == false --> hide chat tool bar so we can't send any message
        if conversation.isMyBottle {
            inputToolbar.isHidden = false
            chatBlockedContainer.isHidden = true
            chatPendingContainer.isHidden = true
            initCustomToolBar()
        } else if let is_seen = conversation.is_seen, is_seen == 1 {
            inputToolbar.isHidden = false
            chatBlockedContainer.isHidden = true
            chatPendingContainer.isHidden = true
            initCustomToolBar()
        } else {
            if !isChatBlockedShowedBefore {
                inputToolbar.isHidden = true
                chatBlockedContainer.isHidden = false
                chatPendingContainer.isHidden = false
                isChatBlockedShowedBefore = true
            }
        }
        
        // show chat tutorial on first opening of an unblocked chat
        if let tutShowedBefore = DataStore.shared.me?.homeTutShowed, !tutShowedBefore, chatBlockedContainer.isHidden{
            DataStore.shared.tutorialChatShowed = true
            DataStore.shared.me?.chatTutShowed = true
            dispatch_main_after(2) {
                let viewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ChatTutorial") as! ChatTutorialViewController
                viewController.alpha = 0.5
                self.present(viewController, animated: true, completion: nil)
                if let me = DataStore.shared.me {
                    ApiManager.shared.updateUser(user: me) { (success: Bool, err: ServerError?, user: AppUser?) in }
                }
            }
        }
        
        if let convId = conversationOriginalObject?.idString, let unsentText = DataStore.shared.getConversationsUnsentTextMesssage(key: convId) {
            self.inputToolbar.contentView.textView.text = unsentText
            DataStore.shared.setConversationUnsentMessage(key: convId, text: "")
        }
        
        chatVc.conversationOriginalObject = conversation
        chatVc.conversationId = conversationOriginalObject?.idString
    }
    
    func initNewConversation() {
        
        if let btl = bottleToReplyTo, let bottleOwnerId = btl.ownerId, let url = btl.attachment, let thumbUrl = btl.thumb {
            // send the bottle video as the first message in this
            // conversation on behalf of the peer, so we tomporary make the peer as the sender
            self.senderId = "\(bottleOwnerId)"
            self.submitMessageWithVideoURL(videoUrl: url, thumbURL: thumbUrl)
            
            // put the sender id to its correct state
            if let userId = DataStore.shared.me?.objectId {
                self.senderId = "\(userId)"
            }
            
            //send push notification to bottle owner to inform him about the new reply
            if let peer = btl.owner {
                let msgToSend = String(format: "NOTIFICATION_NEW_REPLY".localized, (DataStore.shared.me?.userName)!)
                let msgToSendAr = String(format: "NOTIFICATION_NEW_REPLY_AR".localized, (DataStore.shared.me?.userName)!)
                ApiManager.shared.sendPushNotification(msg: msgToSend, msg_ar: msgToSendAr, targetUser: peer, chatId: self.conversationId, completionBlock: { (success, error) in })
            }
        }
    }
    
    
    func backButtonAction(_ sender: AnyObject) {
        
        if let unsentText = self.inputToolbar.contentView.textView.text, let convId = conversationOriginalObject?.idString {
            DataStore.shared.setConversationUnsentMessage(key: convId, text: unsentText)
        }
        disposeFirebaseReference()
        
        //if we opened this chat from FindBottleViewContrller to reply to a
        //bottle we should back to the home screen not to the previous screen
        if let _ = bottleToReplyTo {
            self.performSegue(withIdentifier: "unwindSendReply", sender: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        if let _ = AudioManager.shared.audioPlayer {
            AudioManager.shared.stopAudio()
        }
        
        customNavBar.removeFromSuperview()
        recordButton.removeFromSuperview()
        lblRecording.removeFromSuperview()
        ivRecordingIcon.removeFromSuperview()
        recordButtonContainer.removeFromSuperview()
        chatBlockedContainer.removeFromSuperview()
        chatBlockedLabel.removeFromSuperview()
        chatPendingContainer.removeFromSuperview()
        chatPendingLabel.removeFromSuperview()
        chatPendingImageView.removeFromSuperview()
        chatPendingCloseButton.removeFromSuperview()
    }
    
    @IBAction func cloesPandingChatViewAction(_ sender: AnyObject) {
        chatPendingContainer.isHidden = true
    }

    @IBAction func didTapPeerImage(_ sender: AnyObject) {
        if let peerImageUrl = conversationOriginalObject?.getPeer?.profilePic {
            let photo: PreviewPhoto = PreviewPhoto(image: UIImage.init(named: "user_placeholder"), title: "")
            let images = [photo]
            let photosViewController = NYTPhotosViewController(photos: images)
            photosViewController.rightBarButtonItem = nil
            present(photosViewController, animated: true, completion: nil)
            
            SDWebImageDownloader.shared().downloadImage(
                with: URL(string: peerImageUrl),
                options: SDWebImageDownloaderOptions(rawValue: 7),
                progress: nil,
                completed: { (image, data, error, bool) -> Void in
                    DispatchQueue.main.async() {
                      photo.image = image
                        photosViewController.updateImage(for: photo)
                    }
            })
        }
    }

    // MARK: - Keybaord notification
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            var height = keyboardSize.height
//            var heightTop : CGFloat = 0.0
//            // Handle iPhone x
//            if #available(iOS 11.0, *) {
//                if let window = UIApplication.shared.keyWindow {
//                    height += window.safeAreaInsets.bottom
//                    heightTop = window.safeAreaInsets.top
//                }
//            }
            self.recordButtonContainer.frame.origin.y = inputToolbar.frame.origin.y
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            var height = keyboardSize.height
//            // Handle iPhone x
//            if #available(iOS 11.0, *) {
//                if let window = UIApplication.shared.keyWindow {
//                    height += window.safeAreaInsets.bottom
//                }
//            }
            self.recordButtonContainer.frame.origin.y = inputToolbar.frame.origin.y
        }
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
        if isRTL {
            if message.senderId == senderId { // 2
                return incomingBubbleImageView
            } else { // 3
                return outgoingBubbleImageView
            }
        } else {
            // The app is in right-to-left mode
            if message.senderId == senderId { // 2
                return outgoingBubbleImageView
            } else { // 3
                return incomingBubbleImageView
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        let messageWithId = messagesWithId[indexPath.item]
        
        if message.isMediaMessage {
            if message.media is JSQAudioMediaItem {
                let audioItem = message.media as! JSQCustomAudioMediaItem
                
                if message.senderId == senderId {
                    let cell = super.collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCollectionViewCellOutgoing_id", for: indexPath) as! AudioCollectionViewCellOutgoing
                    
                    cell.index = indexPath.row
                    cell.url = audioItem.audioUrl
                    cell.data = audioItem.audioData
                    cell.audioDelegate = self
                
                    if messageWithId == self.lastSeenMessageId {
                        cell.cellBottomLabel.attributedText = seenStr
                    }else {
                        cell.cellBottomLabel.text = ""
                    }
                    
                    if (audioItem.audioUrl?.isValidUrl())! {
                        cell.indicatorView.stopAnimating()
                        cell.indicatorView.isHidden = true
                        cell.playButton.isHidden = false
                    }else{
                        cell.indicatorView.startAnimating()
                        cell.indicatorView.isHidden = false
                        cell.playButton.isHidden = true
                    }
                    
                    return cell
                    
                } else {
                    let cell = super.collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCollectionViewCellIncoming_id", for: indexPath) as! AudioCollectionViewCellIncoming
                    
                    cell.index = indexPath.row
                    cell.url = audioItem.audioUrl
                    cell.data = audioItem.audioData
                    cell.audioDelegate = self
                    
                    if (audioItem.audioUrl?.isValidUrl())! {
                        cell.indicatorView.stopAnimating()
                        cell.indicatorView.isHidden = true
                        cell.playButton.isHidden = false
                    }else{
                        cell.indicatorView.startAnimating()
                        cell.indicatorView.isHidden = false
                        cell.playButton.isHidden = true
                    }
                    
                    return cell
                }
            }
        }
        
        if isRTL {
            if message.senderId == senderId { // 1
                cell.textView?.textColor = UIColor.black // 3
                
            } else {
                cell.textView?.textColor = UIColor.white // 2
            }
        } else {
            if message.senderId == senderId { // 1
                cell.textView?.textColor = UIColor.white // 2
            } else {
                cell.textView?.textColor = UIColor.black // 3
            }
        }
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        let messageWithId = messagesWithId[indexPath.item]
        
        if message.senderId == DataStore.shared.me?.objectId {
            if messageWithId == self.lastSeenMessageId {
                return seenStr
            }else {
                return nil
            }
        }else{
            return nil
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
                    photosViewController.rightBarButtonItem = nil
                    present(photosViewController, animated: true, completion: nil)
                }
            }
            // Video Message
            if mediaItem is JSQCustomVideoMediaItem {
                let videoItem = mediaItem as! JSQCustomVideoMediaItem

                if  let videoUrl = videoItem.message.videoUrl, (videoUrl.hasPrefix("http://") || videoUrl.hasPrefix("https://")) {
                    
                    let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
                    previewControl.from = .chatView
                    previewControl.type = .VIDEO
                    previewControl.videoUrl = NSURL(string: videoUrl)!
                    
                    present(previewControl, animated: false)
                }
            }
        }
        
        // hide keyboard
        //self.inputToolbar.contentView.textView.resignFirstResponder()
        //self.view.endEditing(true)
    }
    
    func closeKeyboard() {
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func fetchConversationByid (convId: String) {
        
        self.conversationRef = FirebaseManager.shared.conversationRef.child(convId)
        self.conversationRef?.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            //print(snapshot)
            let conversation = Conversation(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
            self?.conversationOriginalObject = conversation
            self?.conversationOriginalObject?.idString = snapshot.key
            self?.initWithConversation(conversation: conversation)
            self?.observeMessages()
            self?.observeFirstReply()
            self?.observeMuteAction()
            self?.initNavBar()
        })
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        
        // if we dont have a reference to the conversation yet
        // then we need to fech it first
        // ex when the chat is opened from push notification deep linking
        if let convId = conversationId, conversationRef == nil  {
            conversationRef = FirebaseManager.shared.conversationRef.child(convId)
            if let convRef = conversationRef{
                messageRef = convRef.child("messages")
            }
        } else {
        
            // TODO here we are limiting the conversation messages count
            // we should implement paging
            messageRef = self.conversationRef!.child("messages")
            let messageQuery = messageRef.queryLimited(toLast:2000)
            
            // get messages count
            var messagesCount = 0
            self.conversationRef!.child("messages").observe(.value, with: { [weak self] (snapshot) in
                messagesCount = Int(snapshot.childrenCount)
            } )
            
            // We can use the observe method to listen for new
            // messages being written to the Firebase DB
            newMessageRefHandle = messageQuery.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
    //      let messageData = snapshot.value as! Dictionary<String, String>
                
                //let values = snapshot.value as? NSDictionary
                let message = Message(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
                message.idString = snapshot.key
                
                // check seen messages
                if let selfRef = self {
                    if selfRef.messageCounter == messagesCount || selfRef.messageCounter == messagesCount - 1 {
                        if selfRef.messageCounter == messagesCount - 1 {
                            self?.messageCounter += 1
                        }
                        self?.checkLastSeenMessage(message: message)
                    }else {
                        self?.messageCounter += 1
                    }
                }
                
                if let id = message.senderId, let name = message.senderName, let text = message.text, text.characters.count > 0 {
                    self?.addMessage(withId: id, name: name, text: text)
                    self?.messagesWithId.append(message.idString!)
                    
                    self?.finishReceivingMessage()
                    
                } else if let id = message.senderId, let mediaURL = message.photoUrl {
                    
                    let mediaItem = JSQCustomPhotoMediaItem(message: message, isOperator: id == self?.senderId)
                    self?.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    self?.messagesWithId.append(message.idString!)
                    
                    if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                        mediaItem.message = message
                        self?.fetchImageDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                    
                } else if let id = message.senderId, let mediaURL = message.videoUrl {
                    
                    let mediaItem = JSQCustomVideoMediaItem(message: message, isOperator: id == self?.senderId)
                    self?.addVideoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    self?.messagesWithId.append(message.idString!)
                    
                    if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                        mediaItem.message = message
                        self?.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                    
                } else if let id = message.senderId, let mediaURL = message.audioUrl {
                    
                    //let audioData = NSData(contentsOf: URL(string:mediaURL)!)
                    let audioData = Data()
                    let audioItem = JSQCustomAudioMediaItem(data: audioData as! Data)
                    if let selfRef = self {
                        audioItem.appliesMediaViewMaskAsOutgoing = (id == self?.senderId) == (!selfRef.isRTL)
                    }
                    audioItem.audioUrl = URL(string:mediaURL)!
                    
                    
                    if id != DataStore.shared.me?.objectId {
                        if let url = audioItem.audioUrl, url.isValidUrl() {
                            self?.addAudioMessage(withId: id, key: snapshot.key, mediaItem: audioItem)
                            self?.messagesWithId.append(message.idString!)
                        } else {
                            // dont add the message if its not mine and the url is not valid
                        }
                    } else {
                        self?.addAudioMessage(withId: id, key: snapshot.key, mediaItem: audioItem)
                        self?.messagesWithId.append(message.idString!)
                    }
                   
                    if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                        self?.collectionView.reloadData()
                        self?.audioMessageMap.removeValue(forKey: snapshot.key)
                    }
                    
                } else {
                    print("Error! Could not decode message data")
                }
                self?.scrollToBottom(animated: true)
            })
            
            // We can also use the observer method to listen for
            // changes to existing messages.
            // We use this to be notified when a photo has been stored
            // to the Firebase Storage, so we can update the message data
            updatedMessageRefHandle = messageRef.observe(.childChanged, with: { [weak self] (snapshot) in
           
                let message = Message(json: JSON(snapshot.value as! Dictionary<String, AnyObject>))
                message.idString = snapshot.key
                
                if let mediaURL = message.photoUrl {
                    // The photo has been updated.
                    if let mediaItem = self?.photoMessageMap[message.idString!] {
                        mediaItem.message = message
                        self?.fetchImageDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: message.idString)
                    }
                } else if let mediaURL = message.videoUrl {
                 
                    if let mediaItem = self?.videoMessageMap[message.idString!] {
                        
                        mediaItem.message = message
                        self?.fetchVideoDataAtURL(mediaURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: message.idString)
                    }
                    
                } else if let mediaURL = message.audioUrl {
                    
                    if let mediaItem = self?.audioMessageMap[message.idString!] {
                        
                        let audioData = Data() //NSData(contentsOf: URL(string:mediaURL)!)
                        mediaItem.audioUrl = URL(string:mediaURL)!
                        mediaItem.audioData = audioData
                        self?.collectionView.reloadData()
                        self?.audioMessageMap.removeValue(forKey: message.idString!)
                    } else if let id = message.senderId {
                        // the audio message migh not have been added cuz it was not uploaded yet
                        let audioData = Data()
                        let audioItem = JSQCustomAudioMediaItem(data: audioData as! Data)
                        if let selfRef = self {
                            audioItem.appliesMediaViewMaskAsOutgoing = id == selfRef.senderId
                        }
                        audioItem.audioUrl = URL(string:mediaURL)!
                        
                        if id != DataStore.shared.me?.objectId {
                            if let url = audioItem.audioUrl, url.isValidUrl() {
                                self?.addAudioMessage(withId: id, key: snapshot.key, mediaItem: audioItem)
                                self?.messagesWithId.append(message.idString!)
                            } else {
                                // dont add the message if its not mine and the url is not valid
                            }
                        } else {
                            self?.addAudioMessage(withId: id, key: snapshot.key, mediaItem: audioItem)
                            self?.messagesWithId.append(message.idString!)
                        }
                        
                        if mediaURL.hasPrefix("http://") || mediaURL.hasPrefix("https://") {
                            self?.collectionView.reloadData()
                            self?.audioMessageMap.removeValue(forKey: snapshot.key)
                        }
                    }
                }
                self?.scrollToBottom(animated: true)
            })
        }
        
        // handle seen messages
        if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
            lastSeenMessageRef = self.conversationRef!.child("user2LastSeenMessageId")
            unseenCountRef = self.conversationRef!.child("user1_unseen")
            unseenMessagesCountRefHandle = self.unseenCountRef?.observe(.value, with: { [weak self] (snapshot) -> Void in
                self?.conversationRef?.updateChildValues(["user1_unseen": 0])
            })
            
        } else {
            lastSeenMessageRef = self.conversationRef!.child("user1LastSeenMessageId")
            unseenCountRef = self.conversationRef!.child("user2_unseen")
            unseenMessagesCountRefHandle = self.unseenCountRef?.observe(.value, with: { [weak self] (snapshot) -> Void in
                self?.conversationRef?.updateChildValues(["user2_unseen": 0])
            })
        }
        
        // hande seen message update
        updateLastSeenMessageRefHandle = self.lastSeenMessageRef!.observe(.value, with: { [weak self] (snapshot) -> Void in
        
            if let value = snapshot.value as? String {
                self?.lastSeenMessageId = value
                self?.collectionView.reloadData()
            }
           
        })
    }
    
    private func observeFirstReply() {
        updateFirstReplyRefHandle = self.firstReplyRef.observe(.value, with: { [weak self] (snapshot) -> Void in
            
            if self?.conversationOriginalObject?.bottle?.owner?.objectId != DataStore.shared.me?.objectId {
                print(snapshot.value as! Int)
                if let is_seen = snapshot.value as? Int ,is_seen  == 1 {
                    if let oldValue = self?.conversationOriginalObject?.is_seen, oldValue != is_seen {
                        // this means that the isSeen value has changed
                        self?.inputToolbar.isHidden = false
                        self?.chatBlockedContainer.isHidden = true
                        self?.chatPendingContainer.isHidden = true
                        self?.initCustomToolBar()
                    }
                }
            }
        })
    }
    
    private func observeMuteAction() {
        if let convRef = conversationRef {
            let mutedUserRef : DatabaseReference?
            
            if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
                mutedUserRef = convRef.child("user1ChatMute")
            }else {
                mutedUserRef = convRef.child("user2ChatMute")
            }
            
            updateMuteChatRefHandle = mutedUserRef?.observe(.value, with: { snapshot in
                print(snapshot.value)
                self.isUserMuted = (snapshot.value as? Bool) ?? false
                
            })
            
        }
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
    
    private func checkLastSeenMessage(message : Message) {
        if let id = message.idString , let senderId = message.senderId {
            if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
                if senderId != DataStore.shared.me?.objectId {
                    self.conversationRef?.updateChildValues(["user1LastSeenMessageId" : id])
                }
            }else{
                if senderId != DataStore.shared.me?.objectId {
                    self.conversationRef?.updateChildValues(["user2LastSeenMessageId" : id])
                }
            }
            
        }
    }
    
      private func observeTyping() {
        if let convRef = conversationRef {
            let typingIndicatorRef = convRef.child("typingIndicator")
            userIsTypingRef = typingIndicatorRef.child(senderId)
            userIsTypingRef.onDisconnectRemoveValue()
            usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
            usersTypingQuery.observe(.value) { [weak self] (data: DataSnapshot) in
        
              // You're the only typing, don't show the indicator
              if let selfRef = self, data.childrenCount == 1 && selfRef.isTyping {
                return
              }
        
              // Are there others typing?
              self?.showTypingIndicator = data.childrenCount > 0
              self?.scrollToBottom(animated: true)
            }
        }
      }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        

        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        onNewMessageSent()
        
        // 5
        finishSendingMessage()
        isTyping = false
    }
    
    func sendMediaMessage(mediaType: AppMediaType) -> String? {
        let itemRef = messageRef.childByAutoId()
        
        
        var messageItem = [
            "senderId": senderId!,
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
        if let allMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            picker.mediaTypes = allMediaTypes
        }else {
            picker.mediaTypes = ["public.image","public.movie"]
        }
        
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
    
    private func addAudioMessage(withId id: String, key: String, mediaItem: JSQCustomAudioMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.audioData == nil || mediaItem.audioData?.count == 0) {
                audioMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    func onNewMessageSent() {
        
        // send a push notifications to the peer if the last push notification sent was more than 20 seconds ago
        var shouldSenPushNotification = false
        if let lastNotifDate = lastNotificationSentDate {
            shouldSenPushNotification = (Date().addingTimeInterval(-30.0) >= (lastNotifDate))
        } else {
            shouldSenPushNotification = true
        }
        if shouldSenPushNotification && !self.isUserMuted {
            lastNotificationSentDate = Date()
            if let peer = conversationOriginalObject?.getPeer {
                let msgToSend = String(format: "NOTIFICATION_NEW_MSG".localized, (DataStore.shared.me?.userName)!)
                let msgToSendAr = String(format: "NOTIFICATION_NEW_MSG_AR".localized, (DataStore.shared.me?.userName)!)
                ApiManager.shared.sendPushNotification(msg: msgToSend, msg_ar: msgToSendAr, targetUser: peer, chatId: self.conversationId, completionBlock: { (success, error) in })
            }
        }
        
        // mark the other user as unread
        // if i"m the sender increase the unread count for the peer
        if self.conversationOriginalObject?.bottle?.owner?.objectId == self.senderId {
            if !self.isUserMuted {
                self.conversationRef?.updateChildValues(["user2_unseen": 1])
            }
        } else {
            if !self.isUserMuted {
                self.conversationRef?.updateChildValues(["user1_unseen": 1])
            }
        }
        
        // update the lastUpdate date of the conversation
        self.conversationRef?.updateChildValues(["updatedAt": ServerValue.timestamp()])
    }
    
    func muteUser() {
        if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
            conversationRef?.updateChildValues(["user2ChatMute": true])
            self.conversationOriginalObject?.user2ChatMute = true
        }else {
            conversationRef?.updateChildValues(["user1ChatMute": true])
            self.conversationOriginalObject?.user1ChatMute = true
        }
        
        self.customNavBar.moreOptions.setImage(self.muteImg, for: .normal)
        
    }
    
    func unmuteUser() {
        if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
            conversationRef?.updateChildValues(["user2ChatMute": false])
            self.conversationOriginalObject?.user2ChatMute = false
        }else {
            conversationRef?.updateChildValues(["user1ChatMute": false])
            self.conversationOriginalObject?.user1ChatMute = false
        }
        
        self.customNavBar.moreOptions.setImage(self.unmuteImg, for: .normal)
    }
    
    // MARK: UITextViewDelegate methods
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
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
            self.scrollToBottom(animated: true)
        }
    }
    
    func uploadAudio(audioUrl:URL) {
        if let key = sendMediaMessage(mediaType: .audio) {
            self.upload(url: audioUrl, photo: nil, key:key, mediaType: .audio)
            self.scrollToBottom(animated: true)
        }
    }
    
    func upload(url:URL?, photo: UIImage?,  key:String, mediaType: AppMediaType) {
        
        self.isLoadedMedia = false
        self.numberOfSentMedia += 1
        if mediaType != .audio {
            videoUploadLoader = WavesLoader.showProgressBasedLoader(with:AppConfig.getBottlePath(), on: self.view)
            videoUploadLoader?.rectSize = 200
        }
        
        let uploadCompletionBlock: (_ files: [Media], _ errorMessage: String?) -> Void = { [weak self] (files, errorMessage) in
            self?.videoUploadLoader?.removeLoader(true)
            if errorMessage == nil {
                self?.numberOfSentMedia -= 1
                if let selfRef = self, selfRef.numberOfSentMedia == 0 {
                    self?.isLoadedMedia = true
                }
                self?.retryUploadAttemptsLeft = 2
                self?.setMediaURL(files[0], forPhotoMessageWithKey: key)
                
                self?.onNewMessageSent()
                if let selfRef = self, selfRef.messages.count <= 2 {
                    // this means this was the first reply messsage in the conversation and the chat is not open yet
                    
                    // show explanation message
                    self?.chatPendingContainer.isHidden = false
//
//                    let alertController = UIAlertController(title: "", message: "CHAT_REPLY_SENT_MSG".localized, preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
//                    alertController.addAction(ok)
//                    self.present(alertController, animated: true, completion: nil)
                    
                    Flurry.logEvent(AppConfig.reply_submitted);
                }
                
//                if let audioUrl = self.audioUrl, mediaType == .audio {
//                    let fileManager = FileManager.default
//                    do {
//                        try fileManager.removeItem(at: audioUrl)
//                    } catch {
//                        print("Error clearing record file");
//                    }
//                }
                
            } else {
                self?.isLoadedMedia = true
                print("error uploading")
                self?.retryUploadAttemptsLeft -= 1
                if let selfRef = self, selfRef.retryUploadAttemptsLeft > 0 {
                    self?.upload(url:url, photo: photo,  key: key, mediaType: mediaType)
                }
            }
        }
        
        if let imageObject = photo, mediaType == .image {
            ApiManager.shared.uploadImage(imageData: imageObject, completionBlock: uploadCompletionBlock)
        } else if let mediaURL = url {
            let urls:[URL] = [mediaURL]
            
            ApiManager.shared.uploadMedia(urls: urls, mediaType: mediaType, completionBlock: uploadCompletionBlock, progressBlock: {(progress) in
                if let progressPercent = progress  {
                    self.videoUploadLoader?.progress = CGFloat(progressPercent)
                }
            })
        }
    }
}

// MARK:- ChatNavigationDelegate
extension ChatViewController: ChatNavigationDelegate {
    
    func navLeftBtnPressed() {
        if self.isLoadedMedia {
            self.backButtonAction(self)
            //dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "", message: "UPLOAD_MEDIA_WARNING".localized , preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                //self.dismiss(animated: true, completion: nil)
                self.backButtonAction(self)
            })
            alertController.addAction(ok)
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func moreOptionsBtnPressed() {
        let muteSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var actionTitle = "MUTE".localized
        var isActionMute = false
        
        if self.conversationOriginalObject?.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
            if self.conversationOriginalObject?.user2ChatMute ?? false {
                actionTitle = "UNMUTE".localized
                isActionMute = false
            }else {
                actionTitle = "MUTE".localized
                isActionMute = true
            }
        }else {
            if self.conversationOriginalObject?.user1ChatMute ?? false {
                actionTitle = "UNMUTE".localized
                isActionMute = false
            }else {
                actionTitle = "MUTE".localized
                isActionMute = true
            }
        }
        
        muteSheet.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: {_ in
            isActionMute ? self.muteUser() : self.unmuteUser()
        }))
        muteSheet.addAction(UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil))
        self.present(muteSheet, animated: true, completion: nil)
        
    }
}

//TODO: make custom chat tool bar class
// MARK:- AVAudioRecorderDelegate
extension ChatViewController: AVAudioRecorderDelegate {
    
    fileprivate func initCustomToolBar() {

        let height: Float = Float(inputToolbar.contentView.leftBarButtonContainerView.frame.size.height)
        var image = UIImage(named: "chatMoreOptions")
        let mediaButton = UIButton(type: .custom)
        mediaButton.setImage(image, for: .normal)
        mediaButton.addTarget(self, action: #selector(self.showActionSheet), for: .touchUpInside)
        mediaButton.frame = CGRect(x: 0, y: 0, width: 40, height: CGFloat(height))
        
        image = UIImage(named: "recordSoundMsg")
        let recordButton = UIButton(type: .custom)
        // record button gesture recognizers
        recordButton.setImage(image, for: .normal)
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didPressRecordAudio(_:)))
        longGestureRecognizer.minimumPressDuration = 0.3
        recordButton.addGestureRecognizer(longGestureRecognizer)
        // used to show a tip for the user when cliking on the record button
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTabRecordAudio(_:)))
        recordButton.addGestureRecognizer(tabGestureRecognizer)
        
        recordButton.frame = CGRect(x: 35, y: -5, width: 60, height: CGFloat(height + 10.0))
        inputToolbar.contentView.leftBarButtonItemWidth = 85
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(mediaButton)
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(recordButton)
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
        inputToolbar.contentView.semanticContentAttribute = .forceRightToLeft
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
    
    func camera() {
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image","public.movie"]
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
    
    func didTabRecordAudio(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "", message: "RECORD_LONG_PRESS".localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
        
        self.playBeepSound()
    }
    
    func didPressRecordAudio(_ sender: UILongPressGestureRecognizer){
        //print("Long tap is handled")
        if sender.state == .began {
            
            self.playBeepSound()
            
            //write the function for start recording the voice here
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // show record audio view
                
                self.recordButtonContainer.isHidden = false
                self.recordButtonContainer.frame.origin.y = inputToolbar.frame.origin.y
                self.recordButtonContainer.alpha = 0.0
                self.recordButtonContainer.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 90)
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
                    self.recordButtonContainer.transform = CGAffineTransform.identity
                    self.recordButtonContainer.alpha = 1.0
                }, completion: {(finished: Bool) in })
                
                self.recordButton.setProgress(0.0)
                
                // reset the timer
                self.recordTimer?.invalidate()
                self.recordTimer = nil;
                // run the timer
                self.recordTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                   target: self,
                                                   selector: #selector(self.tickRecorder(timer:)),
                                                   userInfo: nil,
                                                   repeats: true)
                
                // run the timer
                let runner: RunLoop = RunLoop.current
                runner.add(self.recordTimer!, forMode: .defaultRunLoopMode)
                
                var recordingValid = true
                // we clear sound recorder after every recording session
                // so make sure we have a valid one before recording
                if  self.soundRecorder == nil {
                    do {
                        // todo: handle recording permission not granted
                        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try audioSession.setActive(true)
                        
                        try self.soundRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: self.recordSettings)
                        recordingValid = true
                    } catch let error {
                        let errstr = "Error Recording \(error)"
                        print(errstr)
                        let alertController = UIAlertController(title: "", message: errstr, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                        recordingValid = false
                    }
                }
                if recordingValid {
                    self.soundRecorder.prepareToRecord()
                    self.soundRecorder.delegate = self
                    self.soundRecorder.record()
                }
            //}
        }
        else if sender.state == .ended {
            recordTimer?.invalidate()
            stopRecorderTimer()
            recordButton.setProgress(0.0)
            self.playBeepSound()
            //write the function for stop recording the voice here
            
        }
    }
    
  
    func setupRecorder(){
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({ [weak self] (granted: Bool)-> Void in
                if granted {
                    //set category and activate recorder session
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try audioSession.setActive(true)
//                        if let selfRef = self {
//                            try selfRef.soundRecorder = AVAudioRecorder(url: selfRef.directoryURL()!, settings: selfRef.recordSettings)
//                        }
//                        self?.soundRecorder.prepareToRecord()
                    } catch {
                        print("Error Recording");
                    }
                }
            })
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            let alertController = UIAlertController(title: "", message: "RECORD_FAILED_ERROR".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if let url = audioUrl {
                uploadAudio(audioUrl:url)
            }
        }
        soundRecorder = nil
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        let alertController = UIAlertController(title: "Audio recording error", message: error?.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("reqsound.m4a")
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
            self.lblTimerRecording.text = String(format: "%02d", Int(timeOut))
            self.recordButton.setProgress(CGFloat(timeOut/MAX_VIDEO_LENGTH))
        }
    }
    
    func stopRecorderTimer(){
        // stop recording
        self.recordButton.setProgress(0)
        timeOut = 0.0
        recordButtonContainer.isHidden = true
        if soundRecorder != nil {
            soundRecorder.stop()
        }
    }
}

extension ChatViewController : AudioCollectionViewCellIncomingDelegate  {
    func didPressPlayButtonIncoming(_ cell: AudioCollectionViewCellIncoming) {
        if let audioPlayer = AudioManager.shared.audioPlayer {
            if audioPlayer.isPlaying {
                if self.currentAudioIndex == cell.index {
                    AudioManager.shared.stopAudio()
                }else{
                    AudioManager.shared.stopAudio()
                    
                    startNewIncomingAudio(cell)
                }
            }else{
                if self.currentAudioIndex == cell.index {
                    AudioManager.shared.resumeAudio()
                }else{
                    startNewIncomingAudio(cell)
                }
            }
            
            
        }else{
            startNewIncomingAudio(cell)
        }

    }
    func startNewIncomingAudio(_ cell: AudioCollectionViewCellIncoming) {
        if cell.data == nil || cell.data.count <= 0 {
            cell.playButton.isHidden = true
            cell.indicatorView.isHidden = false
            cell.indicatorView.startAnimating()
            AudioManager.shared.getDataFromUrl(url: cell.url, completion: {(data , response , error) in
                DispatchQueue.main.async {
                    
                    cell.playButton.isHidden = false
                    cell.indicatorView.isHidden = true
                    cell.indicatorView.stopAnimating()
                    
                    if error == nil {
                        cell.data = data!
                        (self.messages[cell.index].media as! JSQCustomAudioMediaItem).audioData = data!
                        self.currentAudioIndex = cell.index
                        AudioManager.shared.playAudio(data: data!, progressView: cell.audioProgressView, progressLabel: cell.audioProgressLabel, playButton: cell.playButton)
                    }
                }
            })
        }else{
            self.currentAudioIndex = cell.index
            AudioManager.shared.playAudio(data: cell.data!, progressView: cell.audioProgressView, progressLabel: cell.audioProgressLabel, playButton: cell.playButton)
        }
    }
}

extension ChatViewController : AudioCollectionViewCellOutgoingDelegate  {
    func didPressPlayButtonOutgoing(_ cell: AudioCollectionViewCellOutgoing) {
        if let audioPlayer = AudioManager.shared.audioPlayer {
            if audioPlayer.isPlaying {
                if self.currentAudioIndex == cell.index {
                    AudioManager.shared.stopAudio()
                }else{
                    AudioManager.shared.stopAudio()
                    
                    startNewOutgoingAudio(cell)
                }
            }else{
                if self.currentAudioIndex == cell.index {
                    AudioManager.shared.resumeAudio()
                }else{
                    startNewOutgoingAudio(cell)
                }
            }
        }else{
            startNewOutgoingAudio( cell)
        }
    }
    
    func startNewOutgoingAudio(_ cell: AudioCollectionViewCellOutgoing) {
        if cell.data == nil  || cell.data.count <= 0 {
            cell.playButton.isHidden = true
            cell.indicatorView.isHidden = false
            cell.indicatorView.startAnimating()
            AudioManager.shared.getDataFromUrl(url: cell.url, completion: {(data , response , error) in
                DispatchQueue.main.async {
                    
                    cell.playButton.isHidden = false
                    cell.indicatorView.isHidden = true
                    cell.indicatorView.stopAnimating()
                    
                    if error == nil {
                        cell.data = data!
                        (self.messages[cell.index].media as! JSQCustomAudioMediaItem).audioData = data!
                        self.currentAudioIndex = cell.index
                        AudioManager.shared.playAudio(data: data!, progressView: cell.audioProgressView, progressLabel: cell.audioProgressLabel, playButton: cell.playButton)
                    }
                }
            })
        } else {
            self.currentAudioIndex = cell.index
            AudioManager.shared.playAudio(data: cell.data!, progressView: cell.audioProgressView, progressLabel: cell.audioProgressLabel, playButton: cell.playButton)
        }
    }
}

// beep sound
extension ChatViewController {
    func playBeepSound () {
        // play beep sound
        do {
            // Prepare beep player
            self.beepPlayer = try AVAudioPlayer(contentsOf: beepSound as URL)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            self.beepPlayer.prepareToPlay()
            self.beepPlayer.play()
            
        }catch {}
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

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *), let window = self.window {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: 1.0).isActive = true
        }
    }
}
