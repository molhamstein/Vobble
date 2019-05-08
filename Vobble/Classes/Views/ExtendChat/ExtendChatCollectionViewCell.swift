//
//  ExtendChatCollectionViewCell.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 5/6/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class ExtendChatCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = AppFonts.xSmallBold
        descriptionLabel.font = AppFonts.xBigBold
        buyButton.titleLabel?.font = AppFonts.normalBold

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(shopItemObj: ShopItem) {
        
        mainView.removeGradientLayer()
        buyButton.removeGradientLayer()
        
        mainView.applyGradient(colours: [shopItemObj.secondColor, shopItemObj.firstColor], direction: .diagonal)
        buyButton.applyGradient(colours: [shopItemObj.firstColor, shopItemObj.secondColor], direction: .horizontal)
        
        titleLabel.text = "EXTEND_CHAT_TITLE".localized
        descriptionLabel.text = shopItemObj.title
        
        buyButton.setTitle(String(shopItemObj.price ?? 0.0) + "$", for: .normal)
        
        if let iconUrl = shopItemObj.icon {
            image.sd_setImage(with: URL(string:iconUrl))
        }
        
    }

}
