//
//  NotificationCollectionViewCell.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/15/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class NotificationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
