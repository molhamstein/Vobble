//
//  ThrownBottleCollectionViewCell.swift
//  Vobble
//
//  Created by Emessa Group on 10/22/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

class ThrownBottleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bottleReplies: UILabel!
    @IBOutlet weak var bottleShore: UILabel!
    @IBOutlet weak var bottleThumbnail: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bottleReplies.font = AppFonts.small
        bottleShore.font = AppFonts.bigBold
        
        
    }
    
    func configCell(bottle: Bottle) {
        
        
        bottleReplies.text = String.init(format: "MY_THROWN_BOTTLES_REPLIES_COUNT".localized, bottle.repliesUserCount ?? "0")
        bottleShore.text = bottle.shore?.name_en
        if let iconUrl = bottle.thumb {
            bottleThumbnail.sd_setImage(with: URL(string: iconUrl))
        }
        
        
    }

}
