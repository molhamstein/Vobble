//
//  SocialManager.swift
//
//  Created by Molham Mahmoud on 25/04/16.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

/// - Social Manager
///     - Login Facebook, Twitter and Instagram
///     - Share on social media
///
class SocialManager: NSObject{
    
    //MARK: Shared Instance
    static let shared: SocialManager = SocialManager()
    
    private override init() {
        super.init()
    }    
   
    // MARK: Authorization
    /// Facebook login request
    func facebookLogin(controller: UIViewController, completionBlock: @escaping (_ user: AppUser?, _ success: Bool, _ error: ServerError?) -> Void) {
        let fbLoginManager: LoginManager = LoginManager()
        // ask for email permission
        fbLoginManager.logIn(permissions: ["email"], from: controller) { (result, error) in
            // check errors
            if (error == nil) {
                // check if user grants the permissions
                let fbloginresult : LoginManagerLoginResult = result!
                if (fbloginresult.grantedPermissions != nil) {
                    if (fbloginresult.grantedPermissions.contains("email")) {
                        if ((AccessToken.current) != nil) {
                            GraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name,last_name,picture,email,location{location{country_code}},gender"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil) {
                                    let dict = result as! [String : AnyObject]
                                    if let facebookId = dict["id"] as? String {
                                        let fName = dict["first_name"] as? String
                                        let lName = dict["last_name"] as? String
                                        let userName = (fName?.trimed)! + "." + (lName?.trimed)!
                                        var pictureLink = ""
                                        
                                        //TODO: incase the user didnt have an email we give the user a fake email account
                                        var email = facebookId + AppConfig.fakeMailsSuffix
                                        if let dictMail = dict["email"] as? String {
                                            email = dictMail
                                        }
                                        let gender = "male"
                                        if let picObj = dict["picture"] as? [String : AnyObject], let innerPicObj = picObj["data"] as? [String : AnyObject] {
                                            pictureLink = innerPicObj["url"] as! String
                                        }
                                        // TODO: counreyCode is not being used in the signup api
                                        // send facebook ID to start login process
                                        ApiManager.shared.userFacebookLogin(facebookId: facebookId, fbName: userName, fbToken: AccessToken.current?.tokenString ?? "", email: email, fbGender: gender, imageLink: pictureLink) { (isSuccess, error, user) in
                                            // login success
                                            if ActionDeactiveUser.execute(viewController: controller, user: user, error: error) {
                                                if (isSuccess) {
                                                    completionBlock(user, true , nil)
                                                } else {
                                                    completionBlock(nil, false , error)
                                                }
                                            }
                                        }
                                    } else {
                                        completionBlock(nil, false , ServerError.socialLoginError)
                                    }
                                }  else {
                                    completionBlock(nil, false , ServerError.socialLoginError)
                                }
                            })
                        } else {
                            completionBlock(nil, false , ServerError.socialLoginError)
                        }
                    } else {
                        completionBlock(nil, false , ServerError.socialLoginError)
                    }
                } else {
                    completionBlock(nil, false , ServerError.socialLoginError)
                }
            } else {
                completionBlock(nil, false , ServerError.socialLoginError)
            }
        }
    }
    
    /// Twitter login request
    func twitterLogin(controller: UIViewController, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        TWTRTwitter.sharedInstance().logIn(with: controller, completion: { (session, error) in
            // check errors
            if (error == nil) {
                if (session != nil) {
                    if let accessToken = session?.authToken, let accessTokenSecret = session?.authTokenSecret {
                        // send access token and secret to start login process
                        ApiManager.shared.userTwitterLogin(accessToken: accessToken, secret: accessTokenSecret) { (isSuccess, error, user) in
                            // login success
                            if ActionDeactiveUser.execute(viewController: controller, user: user, error: error) {
                                if (isSuccess) {
                                    completionBlock(true , nil)
                                } else {
                                    completionBlock(false , error)
                                }
                            }
                        }
                    } else {
                        completionBlock(false , ServerError.socialLoginError)
                    }
                } else {
                    completionBlock(false , ServerError.socialLoginError)
                }
            } else {
                completionBlock(false , ServerError.socialLoginError)
            }
        })
    }
    
    /// Instagram login request
    func instagramLogin(controller: UIViewController, completionBlock: @escaping (_ user: AppUser?, _ success: Bool, _ error: ServerError?) -> Void) {
        typealias JSONDictionary = [String:Any]
        // set instagram client ID and redirect URI
        let auth: NSMutableDictionary = ["client_id": AppConfig.instagramClienID, SimpleAuthRedirectURIKey: AppConfig.instagramRedirectURI]
        SimpleAuth.configuration()["instagram"] = auth
        // instagram authorization
        SimpleAuth.authorize("instagram", options: [:]) { (result: Any?, error: Error?) -> Void in
            // check errors
            if (error == nil) {
                let dict = result as! [String : AnyObject]
                if let instagramId = dict["uid"] as? String, let instagramToken = dict["credentials"]?["token"] as? String {
                    let instaUserInfo = dict["user_info"] as! [String : AnyObject]
                    let username = instaUserInfo["username"] as? String
                    let image = instaUserInfo["image"] as? String
                    let userInfoHolder = AppUser()
                    userInfoHolder.userName = username
                    userInfoHolder.profilePic = image
                    userInfoHolder.loginType = .instagram
                    userInfoHolder.socialId = instagramId
                    userInfoHolder.socialToken = instagramToken
                    userInfoHolder.gender = .male
                    userInfoHolder.countryISOCode = "CH"
                    // send instagram ID and token to start login process
                    ApiManager.shared.userInstagramLogin(user: userInfoHolder) { (isSuccess, error, user) in
                        // login success
                        if ActionDeactiveUser.execute(viewController: controller, user: user, error: error) {
                            if (isSuccess) {
                                completionBlock(user, true , nil)
                            } else {
                                completionBlock(nil, false , error)
                            }
                        }
                    }
                } else {
                    completionBlock(nil, false , ServerError.socialLoginError)
                }
            } else {
                completionBlock(nil, false , ServerError.socialLoginError)
            }
        }
    }
    
    func googleLoginResult(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!, completionBlock: @escaping (_ user: AppUser?, _ success: Bool, _ error: ServerError?) -> Void) {
        
        if (error == nil) {
            let userDataHolder = AppUser()
            userDataHolder.userName = user.profile.name
            userDataHolder.socialToken = user.authentication.idToken
            userDataHolder.socialId = user.userID
            userDataHolder.email = user.profile.email
            userDataHolder.profilePic = user.profile.imageURL(withDimension: 200).absoluteString
            userDataHolder.gender = .male
            userDataHolder.loginType = .google
            userDataHolder.countryISOCode = "CH"
            
            ApiManager.shared.userGoogleLogin(user: userDataHolder) { (isSuccess, error, user) in
                // login success
                if (isSuccess) {
                    completionBlock(user, true , nil)
                } else {
                    completionBlock(nil, false , error)
                }
            }
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
            
            // ...
        } else {
            completionBlock(nil, false , ServerError.socialLoginError)
        }
    }
    
    /// Google login request
    func googleLogin(delegateController: LoginViewController) {
        
        GIDSignIn.sharedInstance().clientID = AppConfig.googleClientID
        GIDSignIn.sharedInstance().delegate = delegateController
        GIDSignIn.sharedInstance().uiDelegate = delegateController
        GIDSignIn.sharedInstance().signIn()
        
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().clientID = AppConfig.googleClientID
//        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
//        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
//        GIDSignIn.sharedInstance().signInSilently()
        
        
    }
   
}




