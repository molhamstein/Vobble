//
//  FilterShopCollectionViewCell.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/20/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class FilterShopCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = AppFonts.bigSemiBold
        priceLabel.font = AppFonts.normalBold
        priceLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(shopItemObj: ShopItem) {
        
        mainView.removeGradientLayer()
        mainView.applyGradient(colours: [shopItemObj.firstColor, shopItemObj.secondColor], direction: .horizontal)
        titleLabel.text = shopItemObj.title
        
        if let iconUrl = shopItemObj.icon {
            image.sd_setImage(with: URL(string:iconUrl))
        }
        
        priceLabel.text = String(shopItemObj.priceCoins ?? 0)
        
    }

}
