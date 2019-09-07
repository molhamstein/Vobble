//
//  GiftsCategoryCollectionViewCell.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class GiftsCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var vBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.font = AppFonts.normalSemiBold
        lblTitle.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    func configureCell(_ category: GiftCategory) {
        vBackground.removeGradientLayer()
        vBackground.layer.cornerRadius = self.vBackground.frame.height / 2
        vBackground.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
        
        lblTitle.text = category.name
    }
}
