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
    @IBOutlet weak var notificationImageHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var badgeView: UIView!

//    var mainImageView : UIImageView?  = {
//        var imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    private var imageViewHeight = NSLayoutConstraint()
//    private var imageRatioWidth = CGFloat()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.addSubview(mainImageView!)
//        mainImageView?.leftAnchor.constraint(equalTo: self.mainView.leftAnchor).isActive = true
//        mainImageView?.rightAnchor.constraint(equalTo: self.mainView.rightAnchor).isActive = true
//        mainImageView?.topAnchor.constraint(equalTo: self.mainView.topAnchor).isActive = true
//        mainImageView?.bottomAnchor.constraint(equalTo: self.lblTitle.topAnchor).isActive = true
//
        lblTitle.font = AppFonts.bigSemiBold
        lblDescription.font = AppFonts.normal
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ item : NCenter, tableView: UITableView) {
        self.selectionStyle = .none
        self.lblDescription.text = item.text
        self.lblTitle.text = item.title
        self.backgroundColor = UIColor.clear
        self.notificationImageHeight.constant = 0
        self.badgeView.isHidden = item.isSeen ?? false
        
        if let iconUrl = item.image {
            self.notificationImageHeight.constant = 128
            self.notificationImage?.sd_setImage(with: URL(string: iconUrl))
        }
    }
}
