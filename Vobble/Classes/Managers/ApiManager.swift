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
            print(httpHeaders)
            return httpHeaders
        }
    }
    
    let baseURL = AppConfig.useLiveAPI ? AppConfig.appBaseLiveURL : AppConfig.appBaseDevURL
    
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
            "name": fbName,
            "deviceName": AppConfig.getDeviceId()
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
            "accessTokenSecret": secret,
            "deviceName": AppConfig.getDeviceId()
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
            "name": user.userName!,
            "deviceName": AppConfig.getDeviceId()
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
            "image": user.profilePic ?? "",
            "name": user.userName!,
            "email": user.email!,
            "deviceName": AppConfig.getDeviceId()
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
            "password": password,
            "deviceName": AppConfig.getDeviceId()
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
            "image": " ",
            "deviceName": AppConfig.getDeviceId()
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
        
        var parameters : [String : Any] = [
            "username": user.userName!,
            "gender": user.gender?.rawValue ?? "male",
            "ISOCode" : user.countryISOCode ?? "SA",
            "typeLogIn": (user.loginType?.rawValue)!,
            "registrationCompleted": (user.accountInfoCompleted) ?? false,
            "homeTutShowed": (user.homeTutShowed) ?? false,
            "ChatTutShowed": (user.chatTutShowed) ?? false,
            "tut3Showed": (user.replyTutShowed) ?? false
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
    
    /// User Signup request
    func editUsername(username: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signUpURL = "\(baseURL)/users/editUsername"
        
        let parameters : [String : Any] = [
            "username": username
        ]
        
        // build request
        Alamofire.request(signUpURL, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
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
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    /// get me
    func getMe(completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signUpURL = "\(baseURL)/users/me/?deviceName=\(AppConfig.getDeviceId())"
        
        var customHeaders = headers
        customHeaders["ios-version"] = AppConfig.getBundleVersion()
        print(customHeaders)
        // build request
        Alamofire.request(signUpURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: customHeaders).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    DataStore.shared.me = user
                    NotificationCenter.default.post(name: Notification.Name("ObserveCoins"), object: nil)
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
    
    func requestResendVerify(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        
        let signUpURL = "\(baseURL)auth/resend_code"
        let parameters : [String : String] = [:]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
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
                print(nsError.localizedDescription)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    func signupByPhone(phone: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ code: String?) -> Void) {
        
        let signUpURL = "\(baseURL)/users/signupByPhone"
        let parameters : [String : String] = [
            "phonenumber": phone
        ]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    if let successFlag = jsonResponse["success"].bool, successFlag {
                        completionBlock(true , nil, String(describing: successFlag))
                    }else{
                        completionBlock(false, ServerError.unknownError, nil)
                    }
                    
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
    
    func loginByPhone(phone: String, code: Int, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user: AppUser?) -> Void) {
        
        let loginByPhoneURL = "\(baseURL)/users/loginByPhone"
        let parameters : [String : Any] = [
            "phonenumber": phone,
            "code": code,
            "deviceName": AppConfig.getDeviceId()
        ]
        
        // build request
        Alamofire.request(loginByPhoneURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
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
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
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
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
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
        let bottleURL = "\(baseURL)/userActive/newLogin"
        
        let parameters : [String : Any] = [
            "ownerId": (DataStore.shared.me?.objectId)!,
            "deviceName": AppConfig.getDeviceId()
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
    
    /// just informs the api that the user has replies to a bottle
    /// the actuall reply is sent over FireBase
    func replyToBottle(bottle: Bottle, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/replies"
        
        let parameters : [String : Any] = [
            "userId": (DataStore.shared.me?.objectId)!,
            "bottleId": bottle.bottle_id!
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
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
    
    func markBottleSeen(bottle: Bottle, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/bottleUserCompletes"
        
        let parameters : [String : Any] = [
            "bottleId": bottle.bottle_id!,
            "userId": (DataStore.shared.me?.objectId)!
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

    
    func onReplyOpened(conversation: Conversation, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/activeChat"
        
        var notificationDate = Date().addingTimeInterval(AppConfig.chatValidityafterSeen / 1000.0)
        // noify before 3 hours
        notificationDate = notificationDate.addingTimeInterval((60 * 60 * 3 * -1))
        let parameters : [String : Any] = [
            "chatId": conversation.idString ?? " ",
            "firstUser": DataStore.shared.me?.objectId ?? " ",
            "secondUser": conversation.user?.objectId ?? " "
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
                let _ : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    // MARK: Topics
    func requestTopics(completionBlock: @escaping (_ topics: Array<Topic>?, _ error: NSError?) -> Void) {
        let topicsListURL = "\(baseURL)/topics?filter[where][status]=active&filter[order]=createdAt%20DESC"
        Alamofire.request(topicsListURL).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let topics: [Topic] = data.map{Topic(json: $0)}
                    //save to cache
                    DataStore.shared.topics = topics
                    completionBlock(topics, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
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
                print(resJson)
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
    
    func chatProducts(completionBlock: @escaping (_ categories: Array<GiftCategory>?, _ error: NSError?) -> Void) {
        let giftsListURL = "\(baseURL)/baseChatProducts/getAllChatProduct"
        Alamofire.request(giftsListURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                print(resJson)
                if let data = resJson.array {
                    let giftCategories: [GiftCategory] = data.map{GiftCategory(json: $0)}
                    //save to cache
                    DataStore.shared.giftCategory = giftCategories
                    completionBlock(giftCategories, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
            }
        }
    }

    func purchaseChatProduct(productId: String?, relatedUserId: String?, completionBlock: @escaping (_ error: NSError?) -> Void) {
        let purchaseChatProductURL = "\(baseURL)/chatItems"
        
        let parameters : [String : Any] = [
            "chatProductId" : productId ?? "",
            "relatedUserId" : relatedUserId ?? ""
        ]
        
        Alamofire.request(purchaseChatProductURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                print(resJson)
                completionBlock(nil)
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(error)
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
    func purchaseItem(shopItem: ShopItem, relatedUserId: String? = nil, recienptBase64String: String, transactionId: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ item:InventoryItem?) -> Void) {
        // url & parameters
        let bottleURL = "\(baseURL)/items"
        
        let now = Date()
        let startDateStr = DateHelper.getISOStringFromDate(now)
        var endDate = now
        if let validity = shopItem.validity, validity > 0 {
            endDate = endDate.addingTimeInterval(validity * 60.0 * 60.0)
        }
        let endDateStr = DateHelper.getISOStringFromDate(endDate)
        
        var parameters : [String : Any] = [
            "storeType": "iTunes",
            "storeToken": "tempStoreToken",
            "isConsumed": true,
            "startAt": startDateStr ?? "",
            "endAt": endDateStr ?? "",
            "valid": true,
            "ownerId": (DataStore.shared.me?.objectId)!,
            "productId": shopItem.idString ?? "",
            "receipt":recienptBase64String,
            "transactionId":transactionId,
            "relatedUserId" : relatedUserId
        ]
        
//        if let theJSONData = try? JSONSerialization.data( withJSONObject: parameters, options: []) {
//            let theJSONText = String(data: theJSONData, encoding: .ascii)
//            print("JSON string = \(theJSONText!)")
//        }
        
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
    
    func purchaseItemByCoins(shopItem: ShopItem, relatedUserId: String? = nil, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ item:InventoryItem?) -> Void) {
        // url & parameters
        let purchaseURL = "\(baseURL)/items/buyProductByCoins"
        
        var parameters : [String : Any] = [
            "productId": shopItem.idString ]
        
        if let relatedUserId = relatedUserId {
            parameters["relatedUserId"] = relatedUserId
        }
        
        // build request
        Alamofire.request(purchaseURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
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
                                print(resJson)
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
        
        var parameters : [String : Any] = [
            "file": bottle.attachment!,
            "thumbnail": bottle.thumb!,
            "status": bottle.status!,
            "ownerId": bottle.ownerId!,
            "shoreId": bottle.shoreId!
        ]
        
        if let topicId = bottle.topicId, topicId.length > 0 {
            parameters["topicId"] = topicId
        }
        
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
    
    // MARK: - p bottles
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
        

        var findBottleURL : String;
        if AppConfig.isProductionBuild {
            findBottleURL = "\(baseURL)/bottles/getOneBottle"
        } else {
            findBottleURL = "\(baseURL)/bottles/5c20f1f94c6c42445da94e7b"
        }
        
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
    
    func findBottles(gender: String, countryCode: String, shoreId: String? ,seen: [String]?, complete: [String]?, offsets: Double? = nil, completionBlock: @escaping (_ bottles: [Bottle]?, _ errorMessage: ServerError?) -> Void) {
        
        
        var findBottleURL : String;
        if AppConfig.isProductionBuild {
            findBottleURL = "\(baseURL)/bottles/getBottle"
        } else {
            findBottleURL = "\(baseURL)/bottles/5c20f1f94c6c42445da94e7b"
        }
        
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
        
        if let seen = seen {
            findBottleURL += "&seen=\(seen)"
        }
        
        if let complete = complete {
            findBottleURL += "&complete=\(complete)"
        }
        
        if let offsets = offsets {
            findBottleURL += "&offsets=\(offsets)"
        }
        
        let encoedeUrl = findBottleURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(encoedeUrl!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                print(resJson)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: resJson["error"]) ?? ServerError.unknownError
                    completionBlock(nil , serverError)
                } else {
                    if let bottles = resJson.array {
                        var tempBottles: [Bottle] = []
                        for i in bottles {
                            tempBottles.append(Bottle(json: i))
                        }
                        
                        completionBlock(tempBottles, nil)
                    }
                }
                if responseObject.result.isFailure {
                    let _ : NSError = responseObject.result.error! as NSError
                    completionBlock(nil, ServerError.connectionError)
                }
            }
        }
    }
    
    
    func findBottleById(bottleId:String, completionBlock: @escaping (_ bottle: [Bottle]?, _ errorMessage: ServerError?) -> Void) {
        
        let findBottleURL = "\(baseURL)/bottles/getBottleById/\(bottleId)"
        
        Alamofire.request(findBottleURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: resJson["error"]) ?? ServerError.unknownError
                    completionBlock(nil , serverError)
                } else {
                    
                    let bottle = [Bottle(json: resJson)]
                    completionBlock(bottle, nil)
                }
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
                let _ : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }

    func getNotificationsCenter(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let url = "\(baseURL)/notificationCenters/getMyCenterNotification"
        
        // build request
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                    
                } else {
                    if let data = jsonResponse.array {
                        let notifications: [NCenter] = data.map{NCenter(json: $0)}
                        DataStore.shared.notificationsCenter = notifications
                        
                        NotificationCenter.default.post(name: Notification.Name("ObserveNotificationCenter"), object: nil)
                        
                        completionBlock(true , nil)
                    }
                    
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let _ : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }

    func seenNotifications(ids: [String], completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let url = "\(baseURL)/notificationCenters/makeNotificationSeen"
        
        let parameters: Parameters = ["notificationIds" : ids]
        // build request
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse["error"]) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                    
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                let _ : NSError = responseObject.result.error! as NSError
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }

    
    // MARK: Get thrown bottles
    func requestThwonBottles(completionBlock: @escaping (_ bottles: Array<Bottle>?, _ error: NSError?) -> Void) {
        let thrownBottlesListURL = "\(baseURL)/users/\(DataStore.shared.me?.objectId ?? "")/myBottles"
        Alamofire.request(thrownBottlesListURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers ).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array {
                    let bottles: [Bottle] = data.map{Bottle(json: $0)}
                    //save to cache
                    DataStore.shared.thrownBottles = bottles
                    completionBlock(bottles, nil)
                }
            }
            if responseObject.result.isFailure {
                let error : NSError = responseObject.result.error! as NSError
                completionBlock(nil, error)
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
        case youCanNotEditUsername = 423
        case invalidUserName = 405
        case noBottleFound = 406
        case emailAlreadyExists = 413
        case wrongCode = 418
        case usernameAlreadyExists = 422
        case noEnoughCoins = 424
        case emailAlreadyRegisteredWithDifferentMedia = 412
        case alreadyExists = 101
        case socialLoginFailed = -110
		case notRegistred = 102
        case missingInputData = 104
        case expiredVerifyCode = 107
        case invalidVerifyCode = 108
        case userNotFound = 404
        case invalidPurchase = 415
        case accountDeactivated = 416
        case deviceBlocked = 419
        case noEnoughReplies = 421
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
                case .usernameAlreadyExists:
                    return "ERROR_USERNAME_EXISTS".localized
                case .invalidPurchase:
                    return "SHOP_INVALID_PURCHASE_MSG".localized
                case .deviceBlocked:
                    return "ERROR_DEVICE_BLOCKED".localized
                case .accountDeactivated:
                    return "ERROR_ACOUNT_DEACTIVATED".localized
                case .emailAlreadyRegisteredWithDifferentMedia:
                    return "ERROR_WRONG_LOGIN_METHOD".localized
                case .wrongCode:
                    return "ERROR_WRONG_CODE".localized
                case .youCanNotEditUsername:
                    return "CAN_NOT_EDIT_USERNAME".localized
                case .noEnoughCoins:
                    return "ERROR_NO_ENOUGH_COINS".localized
                case .noEnoughReplies:
                    return "ERROR_NO_ENOUGH_REPLIES".localized
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


