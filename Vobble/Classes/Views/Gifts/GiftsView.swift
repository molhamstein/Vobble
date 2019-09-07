//
//  GiftsView.swift
//  Vobble
//
//  Created by Abd Hayek on 9/4/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class GiftsView: AbstractNibView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    func setupView(){
        self.categoryCollectionView.register(UINib(nibName: "GiftsCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GiftsCategoryCollectionViewCell")
        self.productsCollectionView.register(UINib(nibName: "ChatProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChatProductCollectionViewCell")

        lblTitle.font = AppFonts.xBigBold
    }
}
