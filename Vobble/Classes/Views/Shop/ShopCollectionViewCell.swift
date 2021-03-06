//
//  ShopCollectionViewCell.swift
//  Vobble
//
//  Created by Bayan on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit


class ShopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowHolderView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var coinsIcon: UIImageView!

    var shadowApplied: Bool! = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = AppFonts.xBigBold
        priceLabel.font = AppFonts.xBigBold
        descriptionLabel.font = AppFonts.small
        buyButton.titleLabel?.font = AppFonts.normalBold
        
        buyButton.setTitle("SHOP_BTN_BUY".localized, for: .normal)
        // Initialization
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(shopItemObj: ShopItem) {
        
        mainView.removeGradientLayer()
        mainView.applyGradient(colours: [shopItemObj.firstColor, shopItemObj.secondColor], direction: .horizontal)
        titleLabel.text = shopItemObj.title
        
        descriptionLabel.text = shopItemObj.description
        if let iconUrl = shopItemObj.icon {
            image.sd_setImage(with: URL(string:iconUrl))
        }
        
        if shopItemObj.type == ShopItemType.coinsPack {
            self.coinsIcon.isHidden = true
            priceLabel.text = String(shopItemObj.price ?? 0.0) + " $"
        }else {
            self.coinsIcon.isHidden = false
            priceLabel.text = String(shopItemObj.priceCoins ?? 0)
        }
        
    }

    
}
