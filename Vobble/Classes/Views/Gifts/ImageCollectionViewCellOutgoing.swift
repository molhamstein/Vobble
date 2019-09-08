//
//  ImageCollectionViewCellOutgoing.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/8/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ImageCollectionViewCellOutgoing: JSQMessagesCollectionViewCellOutgoing {
    
    @IBOutlet weak var imgGift: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(url: String?) {
        if let iconUrl = url {
            imgGift.sd_setImage(with: URL(string: iconUrl))
        }
    }
}
