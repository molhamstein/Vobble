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
    @IBOutlet var lblSlogan: UILabel!
    @IBOutlet var lblContactUs: UILabel!
    @IBOutlet var lblTerms: UILabel!
    @IBOutlet var lblShare: UILabel!
    @IBOutlet var lblRate: UILabel!
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
        
        lblSlogan.text = "SETTINGS_SLOGAN".localized
        lblContactUs.text = "SETTINGS_CONTACT".localized
        lblTerms.text = "SETTINGS_TERMS".localized
        lblRate.text = "SETTINGS_RATE".localized
        lblShare.text = "SETTINGS_SHARE".localized
        btnLogout.setTitle("SETTINGS_LOGOUT".localized, for: .normal)
        
        lblSlogan.font = AppFonts.normal
        lblContactUs.font = AppFonts.normalBold
        lblTerms.font = AppFonts.normalBold
        lblRate.font = AppFonts.normalBold
        lblShare.font = AppFonts.normalBold
        btnLogout.titleLabel?.font = AppFonts.normalBold
        
        self.showNavBackButton = true
    }
    
    override func backButtonAction(_ sender: AnyObject) {
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

    @IBAction func rateUsAction(_ sender: UIView) {
        ActionRateUs.execute(hostViewController: self)
        //performSegue(withIdentifier: "aboutTermsSegue", sender: self)
    }

    @IBAction func ShareViboAction(_ sender: UIView) {
        
        ActionShareText.execute(viewController: self, text: "SETTINGS_SHARE_MSG".localized, sourceView: lblShare)
        //performSegue(withIdentifier: "aboutTermsSegue", sender: self)
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
