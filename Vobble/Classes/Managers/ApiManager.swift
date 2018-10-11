//
//  ApiManager.swift
//
//  Created by Molham Mahmoud on 25/04/16.
//  Copyright © 2016. All rights reserved.
//

import SwiftyJSON
import Alamofire

/// - Api store do all Networking stuff
///     - build server request 
///     - prepare params
///     - and add requests headers
///     - parse Json response to App data models
///     - parse error code to Server error object
///
class ApiManager: NSObject {

    typealias Payload = (MultipartFormData) -> Void
    
    /// frequent request headers
    var headers: HTTPHeaders{
        get{
            let httpHeaders = [
                "Authorization": ((DataStore.shared.token) != nil) ? (DataStore.shared.token)! : "",
                "Accept-Language": AppConfig.currentLanguage.langCode
            ]
            return httpHeaders
        }
    }
    
    let baseURL = AppConfig.useLiveAPI ? AppConfig.appBaseLiveURL : AppConfig.appBaseDevURL
    let error_domain = "Rombaye"
    
    //MARK: Shared Instance
    static let shared: ApiManager = ApiManager()
    
    private override init(){
        super.init()
    }    
   
   
    // MARK: Authorization
    /// User facebook login request
    func userFacebookLogin(facebookId: String, fbName: String, fbToken: String, email: String, fbGender: String, imageLink: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/users/facebookLogin"
        let parameters : [String : Any] = [
            "socialId": facebookId,
            "token": fbToken,
            "gender": fbGender,
            "image": imageLink,
            "email": email,
            "name": fbName
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.token = jsonResponse["id"].string
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User twitter login request
    func userTwitterLogin(accessToken: String, secret: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/twitter/login"
        let parameters : [String : Any] = [
            "accessToken": accessToken,
            "accessTokenSecret": secret
            ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User instagram login request
    func userInstagramLogin(user: AppUser, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/users/instegramLogin"
        let parameters : [String : Any] = [
            "socialId": user.socialId!,
            "token": user.socialToken!,
            "gender": user.gender!.rawValue,
            "image": user.profilePic!,
            "name": user.userName!
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.token = jsonResponse["id"].string
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    func userGoogleLogin(user: AppUser, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/users/googleLogin"
        let parameters : [String : Any] = [
            "socialId": user.socialId!,
            "token": user.socialToken!,
            "gender": user.gender!.rawValue,
            "image": user.profilePic!,
            "name": user.userName!,
            "email": user.email!
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.token = jsonResponse["id"].string
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User login request
    func userLogin(email: String, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/users/login?include=user"
        
        let parameters : [String : Any] = [
            "email": email,
            "password": password
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.token = jsonResponse["id"].string
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                 if let code = responseObject.response?.statusCode, code >= 400 {
                completionBlock(false, ServerError.unknownError, nil)
                 } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User Signup request
    func userSignup(user: AppUser, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        guard password.length > 0,
            let _ = user.email
            else {
                return
        }
        
        let signUpURL = "\(baseURL)/users"
        
        let parameters : [String : String] = [
            "username": user.userName!,
            "gender": user.gender?.rawValue ?? "male",
            "ISOCode" : user.countryISOCode!,
            "email": user.email!,
            "password": password,
            "typeLogIn": "registration",
            "image": " "
        ]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// User Signup request
    func updateUser(user: AppUser, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signUpURL = "\(baseURL)/users/\(user.objectId!)"
        
        var parameters : [String : String] = [
            "username": user.userName!,
            "gender": user.gender?.rawValue ?? "male",
            "ISOCode" : user.countryISOCode!,
            "typeLogIn": (user.loginType?.rawValue)!
        ]
        
        if let email = user.email {
            parameters["email"] = email
        }
        
        if let img = user.profilePic {
            parameters["image"] = img
        }
        
        // build request
        Alamofire.request(signUpURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    DataStore.shared.me = user
                    //DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    /// get me
    func getMe(completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signUpURL = "\(baseURL)/users/\(DataStore.shared.me?.objectId ?? " ")"
        
        // build request
        Alamofire.request(signUpURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    DataStore.shared.me = user
                    //DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    func userVerify(code: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        
        let signUpURL = "\(baseURL)auth/confirm_code"
        let parameters : [String : String] = [
            "code": code
        ]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    func requestResendVerify(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        
        let signUpURL = "\(baseURL)auth/resend_code"
        let parameters : [String : String] = [:]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    // MARK: Reset Password
    /// User forget password
    func forgetPassword(email: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/users/reset"
        let parameters : [String : Any] = [
            "email": email,
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    /// Confirm forget password
    func confirmForgetPassword(email: String, code: String, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/confirm_forgot_password"
        let parameters : [String : Any] = [
            "email": email,
            "code": code,
            "password": password
            ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    DataStore.shared.onUserLogin()
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    func markUserAsActive(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/userActive"
        
        let parameters : [String : Any] = [
            "ownerId": (DataStore.shared.me?.objectId)!
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    // MARK: Categories
    func requestCategories(completionBlock: @escaping (_ categories: Array<Category>?, _ error: NSError?) -> Void) {
        let categoriesListURL = "\(baseURL)categories"
        Alamofire.request(categoriesListURL).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson["data"].array
                {
                    let categories: [Category] = data.map{Category(json: $0)}
                    //save to cache
                    DataStore.shared.categories = categories
                    completionBlock(categories, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }
    
    // MARK: Shop
    func requestShopItems(completionBlock: @escaping (_ categories: Array<ShopItem>?, _ error: NSError?) -> Void) {
        let categoriesListURL = "\(baseURL)/products"
        Alamofire.request(categoriesListURL).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let shopItems: [ShopItem] = data.map{ShopItem(json: $0)}
                    //save to cache
                    DataStore.shared.shopItems = shopItems
                    completionBlock(shopItems, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }
    
    func requestUserInventoryItems(completionBlock: @escaping (_ items: Array<InventoryItem>?, _ error: NSError?) -> Void) {
        let categoriesListURL = "\(baseURL)/items/\(DataStore.shared.me?.objectId)"
        Alamofire.request(categoriesListURL).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let items: [InventoryItem] = data.map{InventoryItem(json: $0)}
                    //save to cache
                    DataStore.shared.inventoryItems = items
                    completionBlock(items, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }
    
    /// create bottle request
    func purchaseItem(shopItem: ShopItem, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ item:InventoryItem?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/items"
        
        let now = Date()
        let startDateStr = DateHelper.getISOStringFromDate(now)
        var endDate = now
        if let validity = shopItem.validity, validity > 0 {
            let calendar = Calendar.current
            endDate = endDate.addingTimeInterval(validity * 60.0 * 60.0)
        }
        let endDateStr = DateHelper.getISOStringFromDate(endDate)
        
        let parameters : [String : Any] = [
            "storeType": "iTunes",
            "storeToken": "tempStoreToken",
            "isConsumed": true,
            "startAt": startDateStr,
            "endAt": endDateStr,
            "valid": true,
            "ownerId": (DataStore.shared.me?.objectId)!,
            "productId": shopItem.idString
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let item = InventoryItem(json: jsonResponse)
                    completionBlock(true , nil, item)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }

    func requesReportTypes(completionBlock: @escaping (_ items: Array<ReportType>?, _ error: NSError?) -> Void) {
        let categoriesListURL = "\(baseURL)/reportTypes"
        Alamofire.request(categoriesListURL).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let items: [ReportType] = data.map{ReportType(json: $0)}
                    //save to cache
                    DataStore.shared.reportTypes = items
                    completionBlock(items, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }
    
    // MARK: Upload Video
    func uploadMedia(urls:[URL], mediaType: AppMediaType, completionBlock: @escaping (_ files: [Media], _ errorMessage: String?) -> Void, progressBlock: @escaping (_ percent: Double?) -> Void ) {
        
//        let mediaURL = "\(baseURL)/uploads/videos/upload"
        var mediaURL = "\(baseURL)/uploadFiles/videos/upload"
        if mediaType == .image {
            mediaURL = "\(baseURL)/uploadFiles/images/upload"
        } else if mediaType == .audio {
            mediaURL = "\(baseURL)/uploadFiles/audios/upload"
        }
        
        let payload : Payload = /*@escaping*/{ multipartFormData in
            for url in urls {
                if mediaType == .image {
                    do {
                        let imageData = try Data(contentsOf: url.absoluteURL)
                        if let img = UIImage(data: imageData), let compressedImg = UIImageJPEGRepresentation(img, 0.65) {
                            multipartFormData.append(compressedImg, withName: "file", fileName: "file", mimeType: "image/png")
                        }
                    } catch let error as NSError  {
                        print(error.localizedDescription)
                    }
                } else {
                    multipartFormData.append(url, withName: "file")
                    print("File size after compression: \(Double( Double(multipartFormData.contentLength) / 1048576.0)) mb")
                }
            }
        }
        
        
        Alamofire.upload(multipartFormData: payload, to: mediaURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            
                switch encodingResult {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (Progress) in
                            print("Upload Progress: \(Progress.fractionCompleted)")
                            progressBlock(Progress.fractionCompleted)
                        })
                        
                        upload.responseJSON { responseObject in
                                    
                            if responseObject.result.isSuccess {
                                        
                                let resJson = JSON(responseObject.result.value!)
                                if let code = responseObject.response?.statusCode, code >= 400 {
                                    let serverError = ServerError(json: resJson["error"]) ?? ServerError.unknownError
                                    completionBlock([] , serverError.type.errorMessage)
                                } else {
                                    if let resArray = resJson.array {
                                        var files: [Media] = []
                                        for  i in 0 ..< resArray.count {
                                            let media = Media(json:resArray[i])
                                            media.type = mediaType
                                            files.append(media)
                                            
//                                            if media.type == .audio {
//                                                print("--------- audioUrl: " + media.fileUrl ?? "empty")
//                                            }
                                        }
                                        completionBlock(files, nil)
                                    } else {
                                        completionBlock([] , ServerError.unknownError.type.errorMessage)
                                    }
                                }
                            } else { // failure
                                        
                                if let code = responseObject.response?.statusCode, code >= 400 {
                                    completionBlock([], ServerError.unknownError.type.errorMessage)
                                } else {
                                    completionBlock([], ServerError.connectionError.type.errorMessage)
                                }
                            }
                    }
                    case .failure(let encodingError):
                        completionBlock([], ServerError.connectionError.type.errorMessage)
                }
        })
    }
    
    // MARK: Upload UIImage
    func uploadImage(imageData:UIImage, completionBlock: @escaping (_ files: [Media], _ errorMessage: String?) -> Void) {
        
        var mediaURL = "\(baseURL)/uploadFiles/images/upload"
        
        let payload : Payload = /*@escaping*/{ multipartFormData in
            if let compressedImg = UIImageJPEGRepresentation(imageData, 0.65) {
                multipartFormData.append(compressedImg, withName: "file", fileName: "file", mimeType: "image/png")
            }
        }
        
        Alamofire.upload(multipartFormData: payload, to: mediaURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    
                                    if responseObject.result.isSuccess {
                                        let resJson = JSON(responseObject.result.value!)
                                        if let resArray = resJson.array {
                                            var files: [Media] = []
                                            for  i in 0 ..< resArray.count {
                                                let media = Media(json:resArray[i])
                                                media.type = .image
                                                files.append(media)
                                            }
                                            completionBlock(files, nil)
                                        }
                                    } else { // failure
                                        if let code = responseObject.response?.statusCode, code >= 400 {
                                            completionBlock([], ServerError.unknownError.type.errorMessage)
                                        } else {
                                            completionBlock([], ServerError.connectionError.type.errorMessage)
                                        }
                                    }
                                }
                            case .failure(let encodingError):
                                completionBlock([], ServerError.connectionError.type.errorMessage)
                            }
        })
    }

    /// create bottle request
    func addBottle(bottle: Bottle, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ bottle:Bottle?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/bottles"
        
        let parameters : [String : Any] = [
            "file": bottle.attachment!,
            "thumbnail": bottle.thumb!,
            "status": bottle.status!,
            "ownerId": bottle.ownerId!,
            "shoreId": bottle.shoreId!
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let bottle = Bottle(json: jsonResponse)
                    completionBlock(true , nil, bottle)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }

    func reportBottle(bottle: Bottle, reportType: ReportType, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/reports"
        
        let parameters : [String : Any] = [
            "bottleId": bottle.bottle_id!,
            "ownerId": (DataStore.shared.me?.objectId)!,
            "reportTypeId":reportType.objectId!
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    func blockUser(user: AppUser, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/blocks"
        
        let parameters : [String : Any] = [
            "userId": user.objectId,
            "ownerId": (DataStore.shared.me?.objectId)!,
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }

    // MARK: - get shores
    func getShores(completionBlock: @escaping (_ shores: Array<Shore>?, _ error: NSError?) -> Void) {
        
        let shoreURL = "\(baseURL)/shores"
        
        Alamofire.request(shoreURL).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let shores: [Shore] = data.map{Shore(json: $0)}
                    //save to cache
                    DataStore.shared.shores = shores
                    completionBlock(shores, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }
    
    // MARK: -  p  bottles
    func findBottle(gender:String, countryCode:String, shoreId:String?, completionBlock: @escaping (_ bottle: Bottle?, _ errorMessage: ServerError?) -> Void) {
        
//        var findhBottleURL = "\(baseURL)/bottles?filter[where][ownerId][neq]="
//
//        if let userId = DataStore.shared.me?.objectId {
//            findhBottleURL += "\(userId)&filter[include]=owner"
//        }
//        
//        if countryCode != "" {
//            findhBottleURL += "&filter[where][owner][countryId]=\(countryCode)"
//        }
//        findhBottleURL += "&filter[where][shoreId]=\(shoreId)"
//        
//        if gender != GenderType.allGender.rawValue {
//            findhBottleURL += "&filter[where][owner][gender]=\(gender)"
//        }
//        
//        findhBottleURL += "&filter[order]=createdAt DESC&filter[limit]=5"
        

        var findBottleURL = "\(baseURL)/bottles/getOneBottle"
        // shore
        if let shore = shoreId {
            findBottleURL += "?shoreId=\(shore)"
        } else {
            findBottleURL += "?dummyParam=d"
        }
        // country
        if countryCode != "" && countryCode != AppConfig.NO_COUNTRY_SELECTED{
            findBottleURL += "&ISOCode=\(countryCode)"
        }
        // gender
        if gender != GenderType.allGender.rawValue {
            findBottleURL += "&gender=\(gender)"
        }
        
        let encoedeUrl = findBottleURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(encoedeUrl!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: resJson["error"]) ?? ServerError.unknownError
                    completionBlock(nil , serverError)
                } else {
                    
                    let bottle = Bottle(json: resJson)
                    completionBlock(bottle, nil)
                    
                    //
//                    if let data = resJson.array, data.count > 0 {
//                        let bottle = Bottle(json: data[0])
//                        completionBlock(bottle, nil)
//                    } else {
//                        // no bottle found
//                        completionBlock(nil, ServerError.noBottleFoundError)
//                    }
//                    if resJson == nil {
//                        completionBlock(nil, "ERROR_BOTTLE_NOT_FOUND".localized)
//                    } else {
//                        if let bottleJson = resJson {
//                            let bottle = Bottle(json: bottleJson)
//                            completionBlock(bottle, nil)
//                        } else {
//                            completionBlock(nil, "ERROR_BOTTLE_NOT_FOUND".localized)
//                        }
//                    }
                }
                
//                let resJson = JSON(responseObject.result.value!)
//                if let data = resJson.array, data.count>0 {
//                    let bottle = Bottle(json: data[Int(arc4random_uniform(UInt32(data.count)))])
//                    completionBlock(bottle, nil)
//                }
                
                //completionBlock(nil, "ERROR_BOTTLE_NOT_FOUND".localized)
            }
            if responseObject.result.isFailure {
                let _ : NSError = responseObject.result.error! as NSError
                completionBlock(nil, ServerError.connectionError)
            }
        }
    }
    
    // MARK: notifications
    func sendPushNotification(msg: String, msg_ar: String, targetUser: AppUser, chatId: String? ,completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/notifications/sendNotification"
        
        let msgBodyParams : [String : Any] = [
            "en": msg,
            "ar": msg_ar
        ]
        
        var parameters : [String : Any] = [
            "content": msgBodyParams,
            "userId": targetUser.objectId!,
            ]
        
        if let chatIdStr = chatId {
            let data : [String : Any] = [
                "chatId": chatIdStr
            ]
            parameters["data"] = data
        }
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let nsError : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }

    
}


/**
 Server error represents custome errors types from back end
 */
struct ServerError {
    
    static let errorCodeConnection = 50
    
    public var errorName:String?
    public var status: Int?
    public var code:Int!
    
    public var type:ErrorType {
        get{
            return ErrorType(rawValue: code) ?? .unknown
        }
    }
    
    /// Server erros codes meaning according to backend
    enum ErrorType:Int {
        case connection = 50
        case unknown = -111
        case authorization = 401
        case userNotActivated = 403
        case invalidUserName = 405
        case noBottleFound = 406
        case emailAlreadyExists = 413
        case emailAlreadyRegisteredWithDifferentMedia = 412
        case alreadyExists = 101
        case socialLoginFailed = -110
		case notRegistred = 102
        case missingInputData = 104
        case expiredVerifyCode = 107
        case invalidVerifyCode = 108
        case userNotFound = 404
        case loginFailed = 601 // temp code
        
        /// Handle generic error messages
        /// **Warning:** it is not localized string
        var errorMessage:String {
            switch(self) {
                case .unknown:
                    return "ERROR_UNKNOWN".localized
                case .connection:
                    return "ERROR_NO_CONNECTION".localized
                case .authorization:
                    return "ERROR_NOT_AUTHORIZED".localized
                case .loginFailed:
                    return "ERROR_LOGIN_FAILED".localized
                case .alreadyExists:
                    return "ERROR_SIGNUP_EMAIL_EXISTS".localized
				case .notRegistred:
                    return "ERROR_SIGNIN_WRONG_CREDIST".localized
                case .missingInputData:
                    return "ERROR_MISSING_INPUT_DATA".localized
                case .expiredVerifyCode:
                    return "ERROR_EXPIRED_VERIFY_CODE".localized
                case .invalidVerifyCode:
                    return "ERROR_INVALID_VERIFY_CODE".localized
                case .userNotFound:
                    return "ERROR_RESET_WRONG_EMAIL".localized
                case .userNotActivated:
                    return "ERROR_UNACTIVATED_USER".localized
                case .invalidUserName:
                    return "ERROR_INVALID_USERNAME".localized
                case .noBottleFound:
                    return "ERROR_BOTTLE_NOT_FOUND".localized
                case .emailAlreadyExists:
                    return "ERROR_EMAIL_EXISTS".localized
            case .emailAlreadyRegisteredWithDifferentMedia:
                return "ERROR_WRONG_LOGIN_METHOD".localized
                
                default:
                    return "ERROR_UNKNOWN".localized
            }
        }
    }
    
    public static var connectionError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.connection.rawValue
            return error
        }
    }
    
    public static var unknownError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.unknown.rawValue
            return error
        }
    }
    
    public static var socialLoginError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.socialLoginFailed.rawValue
            return error
        }
    }
    
    public static var noBottleFoundError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.noBottleFound.rawValue
            return error
        }
    }
    
    public init() {
    }
    
    public init?(json: JSON) {
        guard let errorCode = json["statusCode"].int else {
            return nil
        }
        code = errorCode
        if let errorString = json["message"].string{ errorName = errorString}
        if let statusCode = json["statusCode"].int{ status = statusCode}
        
        if let codeString = json["code"].string, codeString == "LOGIN_FAILED" {
            self.code = ErrorType.loginFailed.rawValue
        }
    }
}


