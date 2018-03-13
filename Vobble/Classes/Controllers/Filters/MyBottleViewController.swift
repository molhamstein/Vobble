//
//  MyBottleViewController.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class MyBottleViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var bottleCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var waveSubView: WaveView!
    
    private var _shopItemsArray:[Bottle] = [Bottle]()
    fileprivate var shopItemsArray:[Bottle] {
        set {
            _shopItemsArray = newValue
        }
        get {
            if(_shopItemsArray.isEmpty){
                _shopItemsArray = [Bottle]()
            }
            return _shopItemsArray
        }
    }
    
    fileprivate var filteredBottles:[Bottle] = [Bottle]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.bottleCollectionView.register(UINib(nibName: "MyBottlesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyBottlesCollectionViewCellID")
        self.initBottleArray()
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }
    
    private func initBottleArray() {
        var bottlrArray:[Bottle] = [Bottle]()
        
        let obj1:Bottle = Bottle()
        obj1.firstColor = AppColors.blueXDark
        obj1.secondColor = AppColors.blueXLight
        obj1.name = "Sundar Pitchai"
        obj1.time = "02:04:12"
        obj1.imageUrl = UIImage(named: "user_placeholder")
        obj1.country = "USA"
        bottlrArray.append(obj1)
        
        let obj2:Bottle = Bottle()
        obj2.firstColor = AppColors.grayXDark
        obj2.secondColor = AppColors.grayXLight
        obj2.name = "Sandar Pitchai2"
        obj2.time = "02:04:12"
        obj2.imageUrl = UIImage(named: "user_placeholder")
        obj2.country = "USA"
        bottlrArray.append(obj2)
        
        let obj3:Bottle = Bottle()
        obj3.firstColor = AppColors.blueXDark
        obj3.secondColor = AppColors.blueXLight
        obj3.name = "Sundar Pitchai3"
        obj3.time = "02:04:12"
        obj3.imageUrl = UIImage(named: "user_placeholder")
        obj3.country = "USA"
        bottlrArray.append(obj3)
        
        let obj4:Bottle = Bottle()
        obj4.firstColor = AppColors.grayXLight
        obj4.secondColor = AppColors.grayXDark
        obj4.name = "Sandar Pitchai"
        obj4.time = "02:04:12"
        obj4.imageUrl = UIImage(named: "user_placeholder")
        obj4.country = "USA"
        bottlrArray.append(obj4)
        
        _shopItemsArray = bottlrArray.map{$0}
    }
    
}
// MARK: - UICollectionViewDataSource
extension MyBottleViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filteredBottles.count > 0 {
            // string contains non-whitespace characters
            return self.filteredBottles.count
        }
        return self.shopItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyBottlesCollectionViewCellID", for: indexPath) as! MyBottlesCollectionViewCell

        if self.filteredBottles.count > 0 {
            let obj = self.filteredBottles[indexPath.row]
            shopCell.configCell(bottleObj: obj )
        } else {
            let obj = self.shopItemsArray[indexPath.row]
            shopCell.configCell(bottleObj: obj )
        }
        
        
        return shopCell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyBottleViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(140)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension MyBottleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
}

// MARK: - textfield delegate
extension MyBottleViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string1 = string
        let string2 = searchTextField.text!
        var searchString = ""
        
        if string.characters.count > 0 { // if it was not delete character
            searchString = string2 + string1
        }
        else if string2.characters.count > 0 { // if it was a delete character
            
            searchString = String(string2.characters.dropLast())
        }
        
        filteredBottles = shopItemsArray.filter{($0.name!.lowercased().contains(searchString.lowercased()))}
        bottleCollectionView.reloadData()
        
        return true
    }
    
    
}

