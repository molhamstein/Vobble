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
class SocialManager: NSObject {
    
    //MARK: Shared Instance
    static let shared: SocialManager = SocialManager()
    
    private override init() {
        super.init()
    }    
   
    // MARK: Authorization
    /// Facebook login request
    func facebookLogin(controller: UIViewController, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        // ask for email permission
        fbLoginManager.logIn(withReadPermissions: ["email"], from: controller) { (result, error) in
            // check errors
            if (error == nil) {
                // check if user grants the permissions
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if (fbloginresult.grantedPermissions != nil) {
                    if (fbloginresult.grantedPermissions.contains("email")) {
                        if ((FBSDKAccessToken.current()) != nil) {
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil) {
                                    let dict = result as! [String : AnyObject]
                                    if let facebookId = dict["id"] as? String {
                                        // send facebook ID to start login process
                                        ApiManager.shared.userFacebookLogin(facebookId: facebookId) { (isSuccess, error, user) in
                                            // login success
                                            if (isSuccess) {
                                                completionBlock(true , nil)
                                            } else {
                                                completionBlock(false , error)
                                            }
                                        }
                                    } else {
                                        completionBlock(false , ServerError.socialLoginError)
                                    }
                                }  else {
                                    completionBlock(false , ServerError.socialLoginError)
                                }
                            })
                        } else {
                            completionBlock(false , ServerError.socialLoginError)
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
                            if (isSuccess) {
                                completionBlock(true , nil)
                            } else {
                                completionBlock(false , error)
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
    func instagramLogin(controller: UIViewController, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
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
                    // send instagram ID and token to start login process
                    ApiManager.shared.userInstagramLogin(userId: instagramId, token: instagramToken) { (isSuccess, error, user) in
                        // login success
                        if (isSuccess) {
                            completionBlock(true , nil)
                        } else {
                            completionBlock(false , error)
                        }
                    }
                } else {
                    completionBlock(false , ServerError.socialLoginError)
                }
            } else {
                completionBlock(false , ServerError.socialLoginError)
            }
        }
    }
}


