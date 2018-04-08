//
//  ProfileViewController.swift
//  Wardah
//
//  Created by Molham Mahmoud on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import MessageUI

class AboutViewController: AbstractController, MFMailComposeViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet var lblContactUs: UILabel!
    @IBOutlet var lblTerms: UILabel!
    @IBOutlet var btnLogout: UIButton!
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
        self.navigationView.title = "ABOUT_TITLE".localized
        
        lblContactUs.text = "SETTINGS_CONTACT".localized
        lblTerms.text = "SETTINGS_TERMS".localized
        btnLogout.setTitle("SETTINGS_LOGOUT".localized, for: .normal)
        
        self.showNavBackButton = true
    }
    
    override func backButtonAction(_ sender: AnyObject) {
        // hide keyboard
        self.navigationController?.dismiss(animated: true, completion: {})
    }
    
    // Build up view elements
    override func buildUp() {
//        loginView.animateIn(mode: .animateInFromBottom, delay: 0.1)
//        centerView.animateIn(mode: .animateInFromBottom, delay: 0.3)
//        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
    }

    @IBAction func contactUsAction(_ sender: UIView) {
        if (MFMailComposeViewController.canSendMail()) {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients([AppConfig.contactUsEmail])
            composeVC.setSubject("Hello!")
            composeVC.setMessageBody("", isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        } else {
            showMessage(message: "mail_not_configured".localized, type: .warning)
        }
    }
    
    @IBAction func viewTermsAction(_ sender: UIView) {
        performSegue(withIdentifier: "aboutTermsSegue", sender: self)
    }
    
    @IBAction func viewPartnersAction(_ sender: UIView) {
//        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "FloristViewController") as! FloristViewController
//        vc.enableSelectFlorist = false
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: UIView) {
        ActionLogout.execute()
    }
}
