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
    
    public var convVC: ConversationViewController?
   
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        
    }
    
    func configCell(userObj: AppUser) {
      
    }
    
    @IBAction func myBottlesButtonPressed(_ sender: Any) {
        convVC?.tap = .myBottles
        convVC?.bottleCollectionView.reloadData()
    }
    
    @IBAction func MyRepliesButtonPressed(_ sender: Any) {
        convVC?.tap = .myReplies
        convVC?.bottleCollectionView.reloadData()
    }
    
    
}
