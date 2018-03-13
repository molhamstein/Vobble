//
//  MyBottlesViewCell.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit


class MyBottlesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatButton: VobbleButton!
    @IBOutlet weak var bottleNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization
        //        mainView.dropShadow()
        chatButton.applyGradient(colours: [AppColors.blueXLight, AppColors.blueXDark], direction: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        mainView.dropShadow()
    }
    
    func configCell(bottleObj: Bottle) {
        
        //        mainView.dropShadow()
        mainView.applyGradient(colours: [bottleObj.firstColor!, bottleObj.secondColor!], direction: .horizontal)
        bottleNameLabel.text = bottleObj.name
        timeLabel.text = "Time left: "+bottleObj.time!
        countryLabel.text = bottleObj.country
        image.image = bottleObj.imageUrl
    }
    
}
