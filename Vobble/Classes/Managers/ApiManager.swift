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
                "Authorization": ((DataStore.shared.me?.token) != nil) ? "JWT " + (DataStore.shared.me?.token)! : "",
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
    func userFacebookLogin(facebookId: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/facebook/login"
        let parameters : [String : Any] = [
            "id": facebookId,
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
    func userInstagramLogin(userId: String, token: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/instagram/login"
        let parameters : [String : Any] = [
            "userId": userId,
            "instagramToken": token
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
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.token = jsonResponse["id"].string
                    DataStore.shared.me = user
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
        guard password.length>0,
            let _ = user.email
            else {
                return
        }
        
        let signUpURL = "\(baseURL)/users"
        
        var parameters : [String : String] = [
            "username": user.firstName!,
            "gender": user.gender?.rawValue ?? "male",
            "country" : "2",
            "email": user.email!,
            "password": password
        ]
        
        
        if let bDate = user.birthday {
            let bDateString = DateHelper.getISOStringFromDate(bDate)
            parameters["birthday"] = bDateString!
        }
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
    
    /// User signup request
    func userSignUpWithImage(user: AppUser, password: String, image:UIImage?, completionBlock: @escaping (_ sucess: Bool, _ error: NSError?) -> Void) {
        
        guard password.length>0,
              let _ = user.email
        else {
            return
        }
        
        let signUpURL = "\(baseURL)auth/signup"
        
        var parameters : [String : Any] = [
            "firstName": user.firstName ?? "",
            "lastName": user.lastName ?? "",
            "email": user.email ?? "",
            "gender": user.gender ?? "",
            "password": password
            ]
        
        if let bDate = user.birthday {
            let bDateString = DateHelper.getISOStringFromDate(bDate)
            parameters["birthday"] = bDateString
        }
        
        let payload : Payload = { multipartFormData in
            
//            if let photo = image, let imageData = UIImageJPEGRepresentation(photo, 0.5){
//                multipartFormData.append(imageData, withName: sign_up_4_image, fileName: "file.png", mimeType: "image/png")
//            }
            
            for (key, value) in parameters{
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }}
        
        Alamofire.upload(multipartFormData: payload, to: signUpURL, method: .post, headers: nil,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    //Request success
                                    if responseObject.result.isSuccess {
                                        let jsonResponse = JSON(responseObject.result.value!)
                                        if let _ = jsonResponse["error"].string {
                                            let errCode = jsonResponse["code"].intValue
                                            let errObj = NSError(domain: self.error_domain, code: errCode, userInfo: nil)
                                            completionBlock(false, errObj)
                                        } else {
                                            //parse user object and save it
                                            let user = AppUser(json: jsonResponse["user"])
                                            DataStore.shared.me = user
                                            completionBlock(true , nil)
                                        }
                                    }
                                    //Network error
                                    if responseObject.result.isFailure {
                                        let error : NSError = responseObject.result.error! as NSError
                                        completionBlock(false, error)
                                    }
                                }
                            case .failure(let encodingError):
                                completionBlock(false, encodingError as NSError?)
                            }
        })
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
        let signInURL = "\(baseURL)auth/forgot_password"
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
    
    
    // MARK: Upload Video
    func uploadMedia(urls:[URL], completionBlock: @escaping (_ files: [Media], _ errorMessage: String?) -> Void) {
        
        let mediaURL = "\(baseURL)/uploads/videos/upload"
        
        let payload : Payload = /*@escaping*/{ multipartFormData in
            
            for url in urls {
                multipartFormData.append(url, withName: "file")
            }
        
        }
        
        Alamofire.upload(multipartFormData: payload, to: mediaURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { responseObject in
                                    
                            if responseObject.result.isSuccess {
                                        
                                let resJson = JSON(responseObject.result.value!)
                                if let resDic = resJson.dictionaryObject {
                                            
                                    if let errorDic = resDic["error"] as? [String: Any] {
                                        print("error")
                                        
                                        let serverError = ServerError(json: resJson.dictionaryValue["error"]!) ?? ServerError.unknownError
                                        completionBlock([], serverError.type.errorMessage)
                                    } else {
                                        if let resJson = resJson.dictionary {
                                        
                                            if let jsonData = resJson["result"], let data = jsonData["files"]["file"].array{
                                            
                                                let files: [Media] = data.map{Media(json: $0)}
                                                    completionBlock(files, nil)
                                                        
                                                        
                                            } else {
                                                        
                                                print("data is nil")
                                                completionBlock([], ServerError.unknownError.type.errorMessage)
                                            }
                                        } else {
                                                    
                                            print("error")
                                            completionBlock([], ServerError.unknownError.type.errorMessage)
                                        }
                                                
                                                
                                    }
                                }
                            } else if responseObject.result.isFailure {
                                        
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
            "attachment": bottle.attachment!,
            "status": bottle.status!,
            "ownerId": bottle.ownerId!,
            "shoreId": bottle.shoreId!
        ]
        
        // build request
        Alamofire.request(bottleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
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
    
    // MARK: - get shores
    func getShores(completionBlock: @escaping (_ shores: Array<Shore>?, _ error: NSError?) -> Void) {
        
        let shoreURL = "\(baseURL)/shores"
        
        Alamofire.request(shoreURL).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array
                {
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
    
    // MARK: -  find bottles
    func findBottle(completionBlock: @escaping (_ bottle: Bottle?, _ error: NSError?) -> Void) {
        
        var findhBottleURL = "\(baseURL)/bottles?filter[where][ownerId][neq]="
        
        if let userId = DataStore.shared.me?.id {
            findhBottleURL += "\(userId)&filter[include]=owner"
        }
        
        Alamofire.request(findhBottleURL).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                
                let resJson = JSON(responseObject.result.value!)
                if let data = resJson.array
                {
                    let bottle = Bottle(json: data[Int(arc4random_uniform(UInt32(data.count)))])
                    
                    completionBlock(bottle, nil)
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
        case authorization = 900
        case alreadyExists = 101
        case socialLoginFailed = -110
		case notRegistred = 102
        case missingInputData = 104
        case expiredVerifyCode = 107
        case invalidVerifyCode = 108
        case userNotFound = 109
        
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
    
    public init() {
    }
    
    public init?(json: JSON) {
        guard let errorCode = json["code"].int else {
            return nil
        }
        code = errorCode
        if let errorString = json["error"].string{ errorName = errorString}
        if let statusCode = json["status"].int{ status = statusCode}
    }
}


