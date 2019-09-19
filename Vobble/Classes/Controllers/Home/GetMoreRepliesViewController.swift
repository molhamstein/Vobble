//
//  GetMoreRepliesViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/18/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class GetMoreRepliesViewController: AbstractController {
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var popUpView: UIView!
    
    private var _repliesItemsArray:[ShopItem] = [ShopItem]()
    fileprivate var repliesItemsArray: [ShopItem] {
        set {
            _repliesItemsArray = newValue
            collectionView.reloadData()
        }
        get {
            if(_repliesItemsArray.isEmpty){
                _repliesItemsArray = [ShopItem]()
            }
            return _repliesItemsArray
        }
    }
    
    var selectedProduct : ShopItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTopTitle.text = String.init(format: "REPLY_POPUP_TITLE".localized, "")
        self.lblTopTitle.font = AppFonts.xBigBold
        
        self.collectionView.register(UINib(nibName: "OutsideShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OutsideShopCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        layoutDesign()
        
        initRepliesArray()
        
        ApiManager.shared.requestShopItems(completionBlock: { (items, error) in
            if error == nil {
                self.initRepliesArray()
            }
        })
    }
    
    private func initRepliesArray() {
        var repliesArray:[ShopItem] = [ShopItem]()
        repliesArray = DataStore.shared.shopItems.filter({$0.type == .replies})
        
        
        self.repliesItemsArray = repliesArray.map{$0}
        
        collectionView.reloadData()
    }
    
    private func layoutDesign(){
        self.popUpView.layer.cornerRadius = 20
        self.popUpView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.popUpView.layer.borderWidth = 0.5
        self.popUpView.layer.masksToBounds = true
        self.popUpView.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        self.popUpView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
    }
    
    @IBAction func close(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
}

extension GetMoreRepliesViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.repliesItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let obj = self.repliesItemsArray[indexPath.row]
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutsideShopCollectionViewCell", for: indexPath) as! OutsideShopCollectionViewCell
        
        
        shopCell.configCell(shopItemObj: obj)
        
        return shopCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.repliesItemsArray[indexPath.row]
        if (DataStore.shared.me?.pocketCoins ?? 0) >= (obj.priceCoins ?? 0) {
            
            let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.priceCoins ?? 0) " + "COINS".localized) , preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                
                self.selectedProduct = obj
                
                // flurry events
                let logEventParams = ["prodType": "reply", "ProdName": self.selectedProduct.title_en ?? ""];
                Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                
                self.showActivityLoader(true)
                
                ApiManager.shared.purchaseItemByCoins(shopItem: obj, completionBlock: {isSuccess, error, shopItem in
                    if error == nil {
                        DataStore.shared.me?.pocketCoins! -= (obj.priceCoins ?? 0)
                        
                        ApiManager.shared.getMe(completionBlock: { (success, err, user) in
                            self.showActivityLoader(false)
                            self.dismiss(animated: true, completion: {})
                            
                        })

                        
                    }else {
                        self.showActivityLoader(false)
                        self.showMessage(message: error?.type.errorMessage ?? "", type: .error)
                    }
                    
                })
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }else {
            
            let alertController = UIAlertController(title: "", message: "NO_ENOUGH_COINS_MSG".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "GET_COINS".localized, style: .default, handler: { (alertAction) in
                
                let shopVC = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: ShopViewController.className) as! ShopViewController
                shopVC.fType = .coinsPack
                
                self.present(shopVC, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        // flurry events
        let logEventParams = ["prodType": "reply"];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
        
    }
    
}


extension GetMoreRepliesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (popUpView.bounds.size.width - 16)
        let itemh = UIScreen.main.bounds.height > 570 ? CGFloat(210) : CGFloat(190)
        
        return CGSize(width: itemW / 3, height: itemh)
    }
}
