//
//  MyBottlesCollectionViewHeader.swift
//  Vobble
//
//  Created by Bayan on 3/14/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

enum tapOption {
    case myBottles
    case myReplies
}

class ConversationCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var searchTetField: UITextField!
    @IBOutlet weak var btnMyBottles: UIButton!
    @IBOutlet weak var btnMyReplies: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageBtn: UIButton!
    
    public var convVC: ConversationViewController?
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        userNameLabel.text = DataStore.shared.me?.firstName
    }
    
    func configCell(userObj: AppUser) {
        
    }
    
    @IBAction func myBottlesButtonPressed(_ sender: Any) {
        convVC?.tap = .myBottles
        convVC?.bottleCollectionView.reloadData()
        btnMyReplies.isSelected = false
        btnMyBottles.isSelected = true
    }
    
    @IBAction func MyRepliesButtonPressed(_ sender: Any) {
        convVC?.tap = .myReplies
        convVC?.bottleCollectionView.reloadData()
        btnMyReplies.isSelected = true
        btnMyBottles.isSelected = false
    }
    
    @IBAction func settingsPressed(_ sender: Any) {

        convVC?.performSegue(withIdentifier: "conversationsSettingsSegue", sender: convVC)

    }
    
    @IBAction func setUserImageBtnPressed(_ sender: Any) {
        
        convVC?.setUserImage(userImage: userImageBtn)
        
    }
}

