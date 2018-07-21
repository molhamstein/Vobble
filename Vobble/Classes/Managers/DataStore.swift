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
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    private var _me:AppUser?
    private var _categories: [Category] = []
    private var _shopItems: [ShopItem] = [ShopItem]()
    private var _inventoryItems: [InventoryItem] = [InventoryItem]()
    private var _reportTypes: [ReportType] = [ReportType]()
    
    private var _myBottles: [Conversation] = [Conversation]()
    private var _myReplies: [Conversation] = [Conversation]()
    
    private var _shores: [Shore] = []
    private var _token: String?
    
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
        }
        get {
            if(_myReplies.isEmpty){
                _myReplies = loadBaseModelArrayForKey(key: CACHE_KEY_MY_REPLIES)
            }
            return _myReplies
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
    }
    
    public func logout() {
        clearCache()
        me = nil
        token = nil
        categories = [Category]()
        myBottles = [Conversation]()
        myReplies = [Conversation]()
        //shopItems = [ShopItem]()
        inventoryItems = [InventoryItem]()
        OneSignal.deleteTags(["user_id","user_name"])
    }
}





