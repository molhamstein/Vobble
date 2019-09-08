//
//  DataStore.swift
//  
//
//  Created by Molham Mahmoud on 14/11/16.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import SwiftyJSON
import OneSignal

/**This class handle all data needed by view controllers and other app classes
 
 It deals with:
 - Userdefault for read/write cached data
 - Any other data sources e.g social provider, contacts manager, etc..
 **Usag:**
 - to write something to chach add constant key and a computed property accessors (set,get) and use the according method  (save,load)
 */
class DataStore :NSObject {
    
    //MARK: Cache keys
    private let CACHE_KEY_CATEGORIES = "categories"
    private let CACHE_KEY_SHORES = "SHORES"
    private let CACHE_KEY_SHOPITEM = "SHOPITEM"
    private let CACHE_KEY_INVENTORY = "INVENTORY_ITEMS"
    private let CACHE_KEY_REPORT_TYPES = "REPORT_TYPES"
    private let CACHE_KEY_USER = "user"
    private let CACHE_KEY_TOKEN = "token"
    private let CACHE_KEY_MY_BOTTLES = "myBottles"
    private let CACHE_KEY_MY_REPLIES = "myReplies"
    private let CACHE_KEY_THROWN_BOTTLES = "thrownBottles"
    private let CACHE_KEY_TUT_1 = "tutorial1"
    private let CACHE_KEY_TUT_CHAT = "tutorialChat"
    private let CACHE_KEY_TUT_CAM = "tutorialCam"
    private let CACHE_KEY_UNSENT_TEXTS = "ChatUnsentTexts"
    private let CACHE_KEY_TOPICS = "topics"
    private let CACHE_KEY_TOPICS_SHOWED = "topicsShowed"
    private let CACHE_KEY_VERSION_CHECKED = "versionChecked"
    private let CACHE_KEY_GIFT_CATEGORY = "giftCategory"
    private let CACHE_KEY_SEEN_VIDEOS = "seenVideos"
    private let CACHE_KEY_COMPLETED_VIDEOS = "completedVideos"
    
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    private var _me:AppUser?
    private var _categories: [Category] = []
    private var _shopItems: [ShopItem] = [ShopItem]()
    private var _inventoryItems: [InventoryItem] = [InventoryItem]()
    private var _reportTypes: [ReportType] = [ReportType]()
    
    private var _myBottles: [Conversation] = [Conversation]()
    private var _myReplies: [Conversation] = [Conversation]()
    private var _allConversations: [Conversation]?
    private var _thrownBottles: [Bottle] = [Bottle]()
    
    private var _shores: [Shore] = []
    private var _token: String?
    
    private var _tutorial1Showed: Bool?
    private var _tutorialChatShowed: Bool?
    private var _tutorialCamShowed: Bool?
    
    private var _topics: [Topic] = [Topic]()
    private var _topicsShowed: Bool = false
    
    private var _versionChecked: Bool = false
    
    private var _giftCategory: [GiftCategory] = []
    
    private var _seenVideos: [String]?
    private var _completedVideos: [String]?
    
    //public var conversationsUnseenMesssages: [String: Int] = [:]
    public var conversationsMyBottlesUnseenMesssages: [String: Int] = [:]
    public var conversationsMyRepliesUnseenMesssages: [String: Int] = [:]
    
    public var conversationsUnmutedUnseenMesssages: [String: Int] = [:]
    
    public var conversationsUnsentTextMesssages: [String: String]?
    
    // user loggedin flag
    var isLoggedin: Bool {
        if let id = token, !id.isEmpty {
            return true
        }
        return false
    }

    // Data in cache
    public var categories: [Category] {
        set {
            _categories = newValue
            saveBaseModelArray(array: _categories, withKey: CACHE_KEY_CATEGORIES)
        }
        get {
            if(_categories.isEmpty){
                _categories = loadBaseModelArrayForKey(key: CACHE_KEY_CATEGORIES)
            }
            return _categories
        }
    }
    
    public var shores: [Shore] {
        set {
            _shores = newValue
            saveBaseModelArray(array: _shores, withKey: CACHE_KEY_SHORES)
        }
        get {
            if(_shores.isEmpty){
                _shores = loadBaseModelArrayForKey(key: CACHE_KEY_SHORES)
            }
            return _shores
        }
    }
    
    public var shopItems: [ShopItem] {
        set {
            _shopItems = newValue
            saveBaseModelArray(array: _shopItems, withKey: CACHE_KEY_SHOPITEM)
        }
        get {
            if(_shopItems.isEmpty){
                _shopItems = loadBaseModelArrayForKey(key: CACHE_KEY_SHOPITEM)
            }
            return _shopItems
        }
    }
    
    public var inventoryItems: [InventoryItem] {
        set {
            _inventoryItems = newValue
            saveBaseModelArray(array: _inventoryItems, withKey: CACHE_KEY_INVENTORY)
        }
        get {
            if(_inventoryItems.isEmpty){
                _inventoryItems = loadBaseModelArrayForKey(key: CACHE_KEY_INVENTORY)
            }
            return _inventoryItems
        }
    }
    
    public var reportTypes: [ReportType] {
        set {
            _reportTypes = newValue
            saveBaseModelArray(array: _reportTypes, withKey: CACHE_KEY_REPORT_TYPES)
        }
        get {
            if(_reportTypes.isEmpty){
                _reportTypes = loadBaseModelArrayForKey(key: CACHE_KEY_REPORT_TYPES)
            }
            return _reportTypes
        }
    }
    public var me:AppUser?{
        set {
            _me = newValue
            saveBaseModelObject(object: _me, withKey: CACHE_KEY_USER)
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
        get {
            if (_me == nil) {
                _me = loadBaseModelObjectForKey(key: CACHE_KEY_USER)
            }
            return _me
        }
    }
    
    public var token:String? {
        set{
            _token = newValue
            if let tokenSting = _token {
                saveStringWithKey(stringToStore: tokenSting, key: CACHE_KEY_TOKEN)
            }
        }
        get {
            if (_token == nil) {
                _token = loadStringForKey(key: CACHE_KEY_TOKEN)
            }
            return _token
        }
    }
    
    public var myBottles: [Conversation] {
        set {
            _myBottles = newValue
            saveBaseModelArray(array: _myBottles, withKey: CACHE_KEY_MY_BOTTLES)
            // force refresh all conversations
            _allConversations = nil
        }
        get {
            if(_myBottles.isEmpty){
                _myBottles = loadBaseModelArrayForKey(key: CACHE_KEY_MY_BOTTLES)
            }
            return _myBottles
        }
    }
    
    public var myReplies: [Conversation] {
        set {
            _myReplies = newValue
            saveBaseModelArray(array: _myReplies, withKey: CACHE_KEY_MY_REPLIES)
            // force refresh all conversations
            _allConversations = nil
        }
        get {
            if(_myReplies.isEmpty){
                _myReplies = loadBaseModelArrayForKey(key: CACHE_KEY_MY_REPLIES)
            }
            return _myReplies
        }
    }
    
    public var thrownBottles: [Bottle] {
        set {
            _thrownBottles = newValue
            saveBaseModelArray(array: _thrownBottles, withKey: CACHE_KEY_THROWN_BOTTLES)
        }
        get {
            if(_thrownBottles.isEmpty){
                _thrownBottles = loadBaseModelArrayForKey(key: CACHE_KEY_THROWN_BOTTLES)
            }
            return _thrownBottles
        }
    }
    
    public var topics: [Topic] {
        set {
            _topics = newValue
            saveBaseModelArray(array: _topics, withKey: CACHE_KEY_TOPICS)
        }
        get {
            if(_topics.isEmpty){
                _topics = loadBaseModelArrayForKey(key: CACHE_KEY_TOPICS)
            }
            return _topics
        }
    }
    
    public var topicsShowed: Bool {
        set {
            _topicsShowed = newValue
            UserDefaults.standard.set(_topicsShowed, forKey: CACHE_KEY_TOPICS_SHOWED)
        }
        get {
            
            _topicsShowed = UserDefaults.standard.bool(forKey: CACHE_KEY_TOPICS_SHOWED)
            
            return _topicsShowed
        }
    }

    public var versionChecked: Bool {
        set {
            _versionChecked = newValue
            UserDefaults.standard.set(_versionChecked, forKey: CACHE_KEY_VERSION_CHECKED)
        }
        get {
            
            _versionChecked = UserDefaults.standard.bool(forKey: CACHE_KEY_VERSION_CHECKED)
            
            return _versionChecked
        }
    }
    
    public var seenVideos: [String]? {
        set {
            _seenVideos = newValue
            if let seen = _seenVideos {
                UserDefaults.standard.set(seen, forKey: CACHE_KEY_SEEN_VIDEOS)
            }
        }
        get {
            if (_seenVideos?.isEmpty ?? true) || _seenVideos == nil {
                _seenVideos = UserDefaults.standard.array(forKey: CACHE_KEY_SEEN_VIDEOS) as? [String]
            }
            return _seenVideos
        }
    }
    
    public var completedVideos: [String]? {
        set {
            _completedVideos = newValue
            if let completed = _completedVideos {
                UserDefaults.standard.set(completed, forKey: CACHE_KEY_COMPLETED_VIDEOS)
            }
        }
        get {
            if (_completedVideos?.isEmpty ?? true) || _completedVideos == nil {
                _completedVideos = UserDefaults.standard.array(forKey: CACHE_KEY_COMPLETED_VIDEOS) as? [String]
            }
            return _completedVideos
        }
    }
    
    public var giftCategory: [GiftCategory] {
        set {
            _giftCategory = newValue
            saveBaseModelArray(array: _giftCategory, withKey: CACHE_KEY_GIFT_CATEGORY)
        }
        get {
            if(_giftCategory.isEmpty){
                _giftCategory = loadBaseModelArrayForKey(key: CACHE_KEY_GIFT_CATEGORY)
            }
            return _giftCategory
        }
    }

    public var allConversations: [Conversation]? {
        set {
            _allConversations = newValue
        }
        get {
            if _allConversations == nil || (_allConversations?.isEmpty ?? true) {
                _allConversations = []
                _allConversations?.append(contentsOf: _myReplies)
                _allConversations?.append(contentsOf: _myBottles)
                /// sort conversations so that most recently updated conversation commes first
                _allConversations?.sort(by: { (obj1, obj2) -> Bool in
                    if let date1 = obj1.updatedAt, let date2 = obj2.updatedAt {
                        return date1 > date2
                    }
                    return true
                })
                
                /// sort the muted people
                var i = 0
                for item in _allConversations ?? []
                {
                    if item.bottle?.owner?.objectId == DataStore.shared.me?.objectId {
                        if item.user2ChatMute ?? false {
                            let element = _allConversations?.remove(at: i)
                            _allConversations?.insert(element!, at: _allConversations?.count ?? 0)
                        }
                    }else {
                        if item.user1ChatMute ?? false {
                            let element = _allConversations?.remove(at: i)
                            _allConversations?.insert(element!, at: _allConversations?.count ?? 0)
                        }
                    }

                    i += 1
                }
            }
            return _allConversations
        }
    }
    
    public var tutorial1Showed:Bool? {
        set{
            _tutorial1Showed = newValue
            if let tutShowed = _tutorial1Showed {
                saveIntWithKey(intToStore: tutShowed ? 1 : 0, key: CACHE_KEY_TUT_1)
            }
        }
        get {
            if (_tutorial1Showed == nil) {
                _tutorial1Showed = (loadIntForKey(key: CACHE_KEY_TUT_1) >= 1) ? true : false
            }
            return _tutorial1Showed
        }
    }
    
    public var tutorialChatShowed:Bool? {
        set{
            _tutorialChatShowed = newValue
            if let tutShowed = _tutorialChatShowed {
                saveIntWithKey(intToStore: tutShowed ? 1 : 0, key: CACHE_KEY_TUT_CHAT)
            }
        }
        get {
            if (_tutorialChatShowed == nil) {
                _tutorialChatShowed = (loadIntForKey(key: CACHE_KEY_TUT_CHAT) >= 1) ? true : false
            }
            return _tutorialChatShowed
        }
    }
    
    public var tutorialCamShowed:Bool? {
        set{
            _tutorialCamShowed = newValue
            if let tutShowed = _tutorialCamShowed {
                saveIntWithKey(intToStore: tutShowed ? 1 : 0, key: CACHE_KEY_TUT_CAM)
            }
        }
        get {
            if (_tutorialCamShowed == nil) {
                _tutorialCamShowed = (loadIntForKey(key: CACHE_KEY_TUT_CAM) >= 1) ? true : false
            }
            return _tutorialCamShowed
        }
    }
    
    public var currentUTCTime:TimeInterval {
        get {
            return Date().timeIntervalSince1970 * 1000
        }
    }
    
    //MARK: Singelton
    public static var shared: DataStore = DataStore()
    
    private override init(){
        super.init()
    }
   
    // conversations
    func getMyBottlesConversationsWithUnseenMessagesCount () -> Int {
        var convCount = 0
        for (_, count) in conversationsMyBottlesUnseenMesssages {
            if count > 0 {
                convCount += 1
            }
        }
        return convCount
    }
    
    func getMyRepliesConversationsWithUnseenMessagesCount () -> Int {
        var convCount = 0
        for (_, count) in conversationsMyRepliesUnseenMesssages {
            if count > 0 {
                convCount += 1
            }
        }
        return convCount
    }
    
    func getConversationsWithUnseenMessagesCount () -> Int {
        
        var convCount = 0
        for (_, count) in conversationsUnmutedUnseenMesssages {
            if count > 0 {
                convCount += 1
            }
        }
        return convCount
        
        //return getMyRepliesConversationsWithUnseenMessagesCount() + getMyBottlesConversationsWithUnseenMessagesCount()
    }
    
    func getConversationsUnsentTextMesssage (key: String) -> String? {
        if conversationsUnsentTextMesssages == nil {
            conversationsUnsentTextMesssages = loadDictionaryForKey(key: CACHE_KEY_UNSENT_TEXTS)
        }
        
        if let text = conversationsUnsentTextMesssages?[key] {
            return text
        }
        return nil
    }
    
    func setConversationUnsentMessage(key:String, text: String) {
        if conversationsUnsentTextMesssages == nil {
            conversationsUnsentTextMesssages = loadDictionaryForKey(key: CACHE_KEY_UNSENT_TEXTS)
        }
        
        conversationsUnsentTextMesssages?[key] = text
        if let messagesDict = conversationsUnsentTextMesssages {
            saveDictionary(dict: messagesDict, withKey: CACHE_KEY_UNSENT_TEXTS)
        }
    }
    
    //MARK: Cache Utils
    private func saveBaseModelArray(array: [BaseModel] , withKey key:String){
        let array : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
        UserDefaults.standard.set(array, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func loadBaseModelArrayForKey<T:BaseModel>(key: String)->[T]{
        var result : [T] = []
        if let arr = UserDefaults.standard.array(forKey: key) as? [[String: Any]]
        {
            result = arr.map{T(json: JSON($0))}
        }
        return result
    }
    
    private func saveDictionary(dict: [String:String] , withKey key:String){
        UserDefaults.standard.set(dict, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func loadDictionaryForKey(key: String)->[String:String]{
        if let dict = UserDefaults.standard.dictionary(forKey: key) as? [String:String] {
            return dict
        }
        return [:]
    }
    
    public func saveBaseModelObject<T:BaseModel>(object:T?, withKey key:String)
    {
        UserDefaults.standard.set(object?.dictionaryRepresentation(), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func loadBaseModelObjectForKey<T:BaseModel>(key:String) -> T?
    {
        if let object = UserDefaults.standard.object(forKey: key)
        {
            return T(json: JSON(object))
        }
        return nil
    }
    
    private func loadStringForKey(key:String) -> String{
        let storedString = UserDefaults.standard.object(forKey: key) as? String ?? ""
        return storedString;
    }
    
    private func saveStringWithKey(stringToStore: String, key: String){
        UserDefaults.standard.set(stringToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    private func loadIntForKey(key:String) -> Int{
        let storedInt = UserDefaults.standard.object(forKey: key) as? Int ?? 0
        return storedInt;
    }
    
    private func saveIntWithKey(intToStore: Int, key: String){
        UserDefaults.standard.set(intToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    public func onUserLogin(){
        if let meId = me?.objectId, let name = me?.userName {
            OneSignal.sendTags(["user_id": meId, "user_name": name])
        }
    }
    
    public func clearCache()
    {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
    
    public func fetchBaseData() {
        ApiManager.shared.getShores(completionBlock: { (shores, error) in})
        ApiManager.shared.requestShopItems(completionBlock: { (shores, error) in})
        ApiManager.shared.requesReportTypes { (reports, error) in}
        
        if let meId = self.me?.objectId, let name = self.me?.userName {
            OneSignal.sendTags(["user_id": meId, "user_name": name])
        }
    }
    
    public func logout() {
        clearCache()
        me = nil
        token = nil
        categories = [Category]()
        myBottles = [Conversation]()
        myReplies = [Conversation]()
        allConversations = []
        tutorial1Showed = false
        tutorialChatShowed = false
        conversationsMyBottlesUnseenMesssages = [:]
        conversationsMyRepliesUnseenMesssages = [:]
        conversationsUnmutedUnseenMesssages = [:]
        //shopItems = [ShopItem]()
        inventoryItems = [InventoryItem]()
        OneSignal.deleteTags(["user_id","user_name"])
    }
}





