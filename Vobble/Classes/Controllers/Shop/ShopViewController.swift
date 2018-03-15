//
//  ShopViewController.swift
//  Vobble
//
//  Created by Bayan on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class ShopViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var genderFilterButton: UIButton!
    @IBOutlet weak var countryFilterButton: UIButton!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
    @IBOutlet weak var waveSubView: WaveView!
    
    private var _shopItemsArray:[ShopItem] = [ShopItem]()
    fileprivate var shopItemsArray:[ShopItem] {
        set {
            _shopItemsArray = newValue
        }
        get {
            if(_shopItemsArray.isEmpty){
                _shopItemsArray = [ShopItem]()
            }
            return _shopItemsArray
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationView.viewcontroller = self
         self.shopCollectionView.register(UINib(nibName: "ShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShopCollectionViewCellID")
         self.initBottleArray()
//        bottlesButton.setTitleColor(UIColor.red, for: .selected)
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }
    
    @IBAction func bottlesBtnPressed(_ sender: Any) {
        self.initBottleArray()
        self.shopCollectionView.reloadData()
    }
    
    @IBAction func genderFilterBtnPressed(_ sender: Any) {
        self.initGenderFilterArray()
        self.shopCollectionView.reloadData()
    }
   
    @IBAction func countryFilterBtnPressed(_ sender: Any) {
    }
    
    
    private func initGenderFilterArray() {
        var genderFilterArray:[ShopItem] = [ShopItem]()
        
        let obj1:ShopItem = ShopItem()
        obj1.firstColor = AppColors.blueXDark
        obj1.secondColor = AppColors.blueXLight
        obj1.title = "Gender Filter"
        obj1.price = "1.5$"
        obj1.imageUrl = UIImage(named: "gender")
        obj1.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        genderFilterArray.append(obj1)
        
        let obj2:ShopItem = ShopItem()
        obj2.firstColor = AppColors.grayXLight
        obj2.secondColor = AppColors.grayXDark
        obj2.title = "Gender Filter"
        obj2.price = "5$"
        obj2.imageUrl = UIImage(named: "gender")
        obj2.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        genderFilterArray.append(obj2)
        
        let obj3:ShopItem = ShopItem()
        obj3.firstColor = AppColors.grayXLight
        obj3.secondColor = AppColors.grayXDark
        obj3.title = "Gender Filter"
        obj3.price = "4.5$"
        obj3.imageUrl = UIImage(named: "gender")
        obj3.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        genderFilterArray.append(obj3)
        
        let obj4:ShopItem = ShopItem()
        obj4.firstColor = AppColors.grayXLight
        obj4.secondColor = AppColors.grayXDark
        obj4.title = "Gender Filter"
        obj4.price = "1.5$"
        obj4.imageUrl = UIImage(named: "gender")
        obj4.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        genderFilterArray.append(obj4)
        
        _shopItemsArray = genderFilterArray.map{$0}
        
    }
    
    private func initBottleArray() {
        var bottlrArray:[ShopItem] = [ShopItem]()
        
        let obj1:ShopItem = ShopItem()
        obj1.firstColor = AppColors.blueXDark
        obj1.secondColor = AppColors.blueXLight
        obj1.title = "3 Bottles"
        obj1.price = "1.5$"
        obj1.imageUrl = UIImage(named: "bottles")
        obj1.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        bottlrArray.append(obj1)
        
        let obj2:ShopItem = ShopItem()
        obj2.firstColor = AppColors.grayXLight
        obj2.secondColor = AppColors.grayXDark
        obj2.title = "3 Bottles"
        obj2.price = "5$"
        obj2.imageUrl = UIImage(named: "bottles")
        obj2.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        bottlrArray.append(obj2)
        
        let obj3:ShopItem = ShopItem()
        obj3.firstColor = AppColors.grayXLight
        obj3.secondColor = AppColors.grayXDark
        obj3.title = "3 Bottles"
        obj3.price = "4.5$"
        obj3.imageUrl = UIImage(named: "bottles")
        obj3.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        bottlrArray.append(obj3)
        
        let obj4:ShopItem = ShopItem()
        obj4.firstColor = AppColors.grayXLight
        obj4.secondColor = AppColors.grayXDark
        obj4.title = "3 Bottles"
        obj4.price = "1.5$"
        obj4.imageUrl = UIImage(named: "bottles")
        obj4.description = "buy 3 bottles so you dont have to wait for the automatic refill"
        bottlrArray.append(obj4)
        
        _shopItemsArray = bottlrArray.map{$0}
    }
    
}
// MARK: - UICollectionViewDataSource
extension ShopViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.shopItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let obj = self.shopItemsArray[indexPath.row]
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCellID", for: indexPath) as! ShopCollectionViewCell
                
        shopCell.configCell(shopItemObj: obj )
        
        return shopCell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShopViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(160)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ShopViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
}
