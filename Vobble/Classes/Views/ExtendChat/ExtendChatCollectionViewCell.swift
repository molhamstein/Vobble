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
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var vPrice: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = AppFonts.xSmallBold
        descriptionLabel.font = AppFonts.xBigBold
        priceLabel.font = AppFonts.normalBold
        priceLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(shopItemObj: ShopItem) {
        
        mainView.removeGradientLayer()
        vPrice.removeGradientLayer()
        
        mainView.applyGradient(colours: [shopItemObj.secondColor, shopItemObj.firstColor], direction: .diagonal)
        vPrice.applyGradient(colours: [shopItemObj.firstColor, shopItemObj.secondColor], direction: .horizontal)
        
        titleLabel.text = "EXTEND_CHAT_TITLE".localized
        descriptionLabel.text = shopItemObj.title
        
        priceLabel.text = String(shopItemObj.price ?? 0.0) + "$"
        
        if let iconUrl = shopItemObj.icon {
            image.sd_setImage(with: URL(string:iconUrl))
        }
        
    }

}
