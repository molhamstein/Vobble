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
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
//        mainView.dropShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        mainView.dropShadow()
    }
    
    func configCell(shopItemObj: ShopItem) {
        
//        mainView.dropShadow()
        mainView.applyGradient(colours: [shopItemObj.firstColor!, shopItemObj.secondColor!], direction: .horizontal)
        titleLabel.text = shopItemObj.title
        priceLabel.text = shopItemObj.price
        descriptionLabel.text = shopItemObj.description
        image.image = shopItemObj.imageUrl
        
    }

    
}
