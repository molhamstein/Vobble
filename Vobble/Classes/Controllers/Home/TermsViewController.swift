//
//  ProfileViewController.swift
//  Wardah
//
//  Created by Molham Mahmoud on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation

enum Terms_type{
    case userAgreement
    case privacyPolicy
}

class TermsViewController: AbstractController {
    
    let PRIVACY_URL_AR: String! = "http://159.65.202.38/terms/privacy_policy.html"
    let PRIVACY_URL_EN: String! = "http://159.65.202.38/terms/privacy_policy.html"
    let TERMS_URL_AR: String! = "http://159.65.202.38/terms/agreement.html"
    let TERMS_URL_EN: String! = "http://159.65.202.38/terms/agreement.html"
    
    var termsType: Terms_type = .privacyPolicy
    
    // MARK: Properties
    @IBOutlet var webView: UIWebView!
    @IBOutlet var navigationView: VobbleNavigationBar!

    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()

        self.navigationView.viewcontroller = self
        self.navigationView.title = ""
        self.showNavBackButton = true
        let url: String!
        if termsType == .privacyPolicy{
            url = (AppConfig.currentLanguage == .arabic) ? self.PRIVACY_URL_AR : self.PRIVACY_URL_EN
        } else {
            url = (AppConfig.currentLanguage == .arabic) ? self.TERMS_URL_AR : self.TERMS_URL_EN
        }
        webView.loadRequest(URLRequest(url: URL(string: url)!))
    }
    
    override func backButtonAction(_ sender: AnyObject) {
        // hide keyboard
        self.navigationController?.popViewController(animated: true)
    }
    
    // Build up view elements
    override func buildUp() {
//        loginView.animateIn(mode: .animateInFromBottom, delay: 0.1)
//        centerView.animateIn(mode: .animateInFromBottom, delay: 0.3)
//        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
    }
    
    @IBAction func viewTermsAction(_ sender: UIView) {
        performSegue(withIdentifier: "aboutTermsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "feedsPostDetailsSegue", let nextScene = segue.destination as? PostDetailsViewController {
        //            nextScene.activePost = selectedPost
        //        } else if segue.identifier == "feedsProfileSegue", let nextScene = segue.destination as? ProfileViewController {
        //            nextScene.activeUser = selectedUser
        //        }
    }
    
}
