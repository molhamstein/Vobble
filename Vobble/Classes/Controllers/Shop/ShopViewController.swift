//
//  ShopViewController.swift
//  Vobble
//
//  Created by Bayan on 3/5/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import  Flurry_iOS_SDK
import StoreKit

class ShopViewController: AbstractController {

    // MARK: Properties
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var genderFilterButton: UIButton!
    @IBOutlet weak var countryFilterButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
    @IBOutlet weak var waveSubView: WaveView!
    
    public var fType: ShopItemType = .bottlesPack
    
    private var _shopItemsArray:[ShopItem] = [ShopItem]()
    fileprivate var shopItemsArray:[ShopItem] {
        set {
            _shopItemsArray = newValue
            shopCollectionView.reloadData()
        }
        get {
            if(_shopItemsArray.isEmpty){
                _shopItemsArray = [ShopItem]()
            }
            return _shopItemsArray
        }
    }
    
    var selectedProduct : ShopItem!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationView.viewcontroller = self
         self.shopCollectionView.register(UINib(nibName: "ShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShopCollectionViewCellID")
        
        bottlesButton.titleLabel?.font = AppFonts.bigBold
        genderFilterButton.titleLabel?.font = AppFonts.bigBold
        countryFilterButton.titleLabel?.font = AppFonts.bigBold
        coinsButton.titleLabel?.font = AppFonts.bigBold
        
        bottlesButton.setTitle("TAB_BOTTLES".localized, for: .normal)
        genderFilterButton.setTitle("TAB_GENDER".localized, for: .normal)
        countryFilterButton.setTitle("TAB_COUNTRY".localized, for: .normal)
        coinsButton.setTitle("TAB_COINS".localized, for: .normal)
        
        self.navigationView.navTitle.text = "SHOP_TITLE".localized
        
        if fType == .bottlesPack {
            bottlesButton.isSelected = true
            self.initBottleArray()
        } else if fType == .countryFilter {
            countryFilterButton.isSelected = true
            self.initCountryFilterArray()
        } else if fType == .genderFilter {
            genderFilterButton.isSelected = true
            self.initGenderFilterArray()
        } else if fType == .coinsPack {
            coinsButton.isSelected = true
            self.initCoinsArray()
        }
        
        self.shopCollectionView.reloadData()
        
    
        ApiManager.shared.requestShopItems(completionBlock: { (shores, error) in})
        
        //IAP Setup
        IAPManager.shared.delegate = self
        IAPManager.shared.currentViewController = self
        
        if !IAPManager.shared.isPaymentsReady() {
            self.shopItemsArray = []
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }

    override
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        IAPManager.shared.cancel()
        super.dismiss(animated: flag, completion: completion)
    }
    
    @IBAction func bottlesBtnPressed(_ sender: Any) {
        self.initBottleArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = true
        genderFilterButton.isSelected = false
        countryFilterButton.isSelected = false
        coinsButton.isSelected = false
    }
    
    @IBAction func genderFilterBtnPressed(_ sender: Any) {
        self.initGenderFilterArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = false
        genderFilterButton.isSelected = true
        countryFilterButton.isSelected = false
        coinsButton.isSelected = false
    }
   
    @IBAction func countryFilterBtnPressed(_ sender: Any) {
        self.initCountryFilterArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = false
        genderFilterButton.isSelected = false
        countryFilterButton.isSelected = true
        coinsButton.isSelected = false
    }
    
    @IBAction func coinsBtnPressed(_ sender: Any) {
        self.initCoinsArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = false
        genderFilterButton.isSelected = false
        countryFilterButton.isSelected = false
        coinsButton.isSelected = true
    }
    
    private func initGenderFilterArray() {
        var genderFilterArray:[ShopItem] = [ShopItem]()
        genderFilterArray = DataStore.shared.shopItems.filter({$0.type == .genderFilter})
        
        
        self.shopItemsArray = genderFilterArray.map{$0}
    }
    
    private func initCountryFilterArray() {
        var countryFilterArray:[ShopItem] = [ShopItem]()
        countryFilterArray = DataStore.shared.shopItems.filter({$0.type == .countryFilter})
        self.shopItemsArray = countryFilterArray.map{$0}
    }
    
    private func initBottleArray() {
        var bottlsArray:[ShopItem] = [ShopItem]()
        bottlsArray = DataStore.shared.shopItems.filter({$0.type == .bottlesPack})
        
        
        self.shopItemsArray = bottlsArray.map{$0}
    }
    
    private func initCoinsArray() {
        var coinsArray:[ShopItem] = [ShopItem]()
        coinsArray = DataStore.shared.shopItems.filter({$0.type == .coinsPack})
        
        
        self.shopItemsArray = coinsArray.map{$0}
    }
    
    override func backButtonAction(_ sender: AnyObject) {
        IAPManager.shared.cancel()
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
        
        
        shopCell.configCell(shopItemObj: obj)
        
        return shopCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShopViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(170)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ShopViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = self.shopItemsArray[indexPath.row]
        
        if bottlesButton.isSelected || coinsButton.isSelected {
            
            let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.price ?? 0.0)") , preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                
                
                if  obj.appleProduct != nil {
                    self.navigationView.showProgressIndicator(show: true)
                    self.view.isUserInteractionEnabled = false
                    print(obj.appleProduct!)
                    if let selectedItem = IAPManager.shared.getProductById(itemId: obj.appleProduct!){
                        //prepare payment
                        self.selectedProduct = obj
                        
                        IAPManager.shared.requestPaymentQueue(product: selectedItem, item: obj)
                        
                        
                        // flurry events
                        var prodType = "bottles"
                        if self.selectedProduct.type == ShopItemType.genderFilter {
                            prodType = "gender"
                        } else if self.selectedProduct.type == ShopItemType.countryFilter {
                            prodType = "country"
                        }else if self.selectedProduct.type == ShopItemType.coinsPack {
                            prodType = "coins"
                        }
                        
                        let logEventParams = ["prodType": prodType, "ProdName": self.selectedProduct.title_en ?? ""];
                        Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                    }else {
                        self.navigationView.showProgressIndicator(show: false)
                        self.view.isUserInteractionEnabled = true
                    }

                }
                
            })
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
            
            var items:[InventoryItem] = [InventoryItem]()
            if genderFilterButton.isSelected {
                items = DataStore.shared.inventoryItems.filter({$0.type == .genderFilter})
            } else if countryFilterButton.isSelected {
                items = DataStore.shared.inventoryItems.filter({$0.type == .countryFilter})
            }
            
            var fTime : TimeInterval = 0
            let currentDate = Date().timeIntervalSince1970
            var seconds = 0.0
            
            if items.count > 0 {
                fTime = items[items.count - 1].endDate ?? 0
                seconds = (fTime - currentDate)
            }
            
            
            if seconds <= 0 {
                let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.price ?? 0.0)") , preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                    
                    if  obj.appleProduct != nil {
                        self.navigationView.showProgressIndicator(show: true)
                        self.view.isUserInteractionEnabled = false
                        if let selectedItem = IAPManager.shared.getProductById(itemId: obj.appleProduct!){
                            self.selectedProduct = obj
                            
                            IAPManager.shared.requestPaymentQueue(product: selectedItem, item: obj)
                            
                            // flurry events
                            var prodType = "bottles"
                            if self.selectedProduct.type == ShopItemType.genderFilter {
                                prodType = "gender"
                            } else if self.selectedProduct.type == ShopItemType.countryFilter {
                                prodType = "country"
                            }
                            let logEventParams = ["prodType": prodType, "ProdName": self.selectedProduct.title_en ?? ""];
                            Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                            
                        }else{
                            self.navigationView.showProgressIndicator(show: false)
                            self.view.isUserInteractionEnabled = true
                        }
                        
                    }
                    
                })
                
                let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
                alertController.addAction(cancel)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                let alertController = UIAlertController(title: "", message: "CANT_BUY_ITEM_WARNING".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok".localized, style: .default,  handler: nil)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        
        // flurry events
        var prodType = "bottles"
        if obj.type == ShopItemType.genderFilter {
            prodType = "gender"
        } else if obj.type == ShopItemType.countryFilter {
            prodType = "country"
        } else if obj.type == ShopItemType.coinsPack {
            prodType = "coins"
        }
        
        let logEventParams = ["prodType": prodType];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
        
    }
    
}

// MARK:- IAPManagerDelegate
extension ShopViewController: IAPManagerDelegate {
    
    func didFailWithError(isAPIError: Bool, error: Error?, serverError: String?){
        self.navigationView.showProgressIndicator(show: false)
        self.view.isUserInteractionEnabled = true
        
        if isAPIError {
            if let err = serverError {
                let alert = UIAlertController(title: "GLOBAL_ERROR_TITLE".localized, message: err , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else {
            if let error = error {
                let failAlert = UIAlertController(title: "GLOBAL_ERROR_TITLE".localized , message: error.localizedDescription, preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: {_ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(failAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    func didPaymentCompleted() {
        self.dismiss(animated: true, completion: {})
        
        self.navigationView.showProgressIndicator(show: false)
        self.view.isUserInteractionEnabled = true
    }

}
