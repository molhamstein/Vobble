//
//  ChatProductCollectionViewCell.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class ChatProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.font = AppFonts.small
        lblPrice.font = AppFonts.normalSemiBold
    }

    func configureCell(_ product: ChatProduct?) {
        lblPrice.text = String(product?.price ?? 0)
        lblTitle.text = product?.name
        
        if let iconUrl = product?.icon {
            print(iconUrl)
            imgIcon.sd_setImage(with: URL(string:iconUrl))
        }
    }
}
