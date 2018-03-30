//
//  FilterColorCell.swift
//  Vobble
//
//  Created by Molham Mahmoud on 11/23/17.
//  Copyright © 2017 Brain-socket. All rights reserved.
//

import UIKit

class ShoreCell: UICollectionViewCell {

    
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnThrow: VobbleButton!

    var shore:Shore?{
        
        didSet{
            guard let shore = shore else{
                return
            }
            lblTitle.text = shore.name
            ivCover.sd_setShowActivityIndicatorView(true)
            ivCover.sd_setIndicatorStyle(.gray)
            ivCover.sd_setImage(with: URL(string: shore.cover!))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        btnThrow.applyGradient(colours: [AppColors.blueXDark, AppColors.blueXLight], direction: .horizontal)
//        btnThrow.dropShadow()
//        ivCover.dropShadow()
        //backGroundView.makeRounded()
        //checkImage.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
