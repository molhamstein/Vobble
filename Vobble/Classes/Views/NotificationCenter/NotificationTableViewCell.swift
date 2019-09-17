//
//  NotificationTableViewCell.swift
//  Vobble
//
//  Created by Abd Hayek on 9/16/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
