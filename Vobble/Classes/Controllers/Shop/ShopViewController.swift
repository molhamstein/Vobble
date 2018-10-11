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
    
    var inAppPurchaseList = [SKProduct]()
    
    // MARK: Properties
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var genderFilterButton: UIButton!
    @IBOutlet weak var countryFilterButton: UIButton!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
    @IBOutlet weak var waveSubView: WaveView!
    
    public var fType:ShopItemType = .bottlesPack
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationView.viewcontroller = self
         self.shopCollectionView.register(UINib(nibName: "ShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShopCollectionViewCellID")
        
        bottlesButton.titleLabel?.font = AppFonts.bigBold
        genderFilterButton.titleLabel?.font = AppFonts.bigBold
        countryFilterButton.titleLabel?.font = AppFonts.bigBold
        
        bottlesButton.setTitle("TAB_BOTTLES".localized, for: .normal)
        genderFilterButton.setTitle("TAB_GENDER".localized, for: .normal)
        countryFilterButton.setTitle("TAB_COUNTRY".localized, for: .normal)
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
        }
        
        self.shopCollectionView.reloadData()
        
        ApiManager.shared.requestShopItems(completionBlock: { (shores, error) in})
        
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(array: ShopItemID.getListId())
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }
    
    @IBAction func bottlesBtnPressed(_ sender: Any) {
        self.initBottleArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = true
        genderFilterButton.isSelected = false
        countryFilterButton.isSelected = false
    }
    
    @IBAction func genderFilterBtnPressed(_ sender: Any) {
        self.initGenderFilterArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = false
        genderFilterButton.isSelected = true
        countryFilterButton.isSelected = false
    }
   
    @IBAction func countryFilterBtnPressed(_ sender: Any) {
        self.initCountryFilterArray()
        self.shopCollectionView.reloadData()
        
        bottlesButton.isSelected = false
        genderFilterButton.isSelected = false
        countryFilterButton.isSelected = true
    }
    
    private func initGenderFilterArray() {
        var genderFilterArray:[ShopItem] = [ShopItem]()
        genderFilterArray = DataStore.shared.shopItems.filter({$0.type == .genderFilter})
        
//        let date = Date().timeIntervalSince1970 * 1000 + (24*60*60*1000)
//
//        let obj1:ShopItem = ShopItem()
//        obj1.firstColor = AppColors.blueXDark
//        obj1.secondColor = AppColors.blueXLight
//        obj1.title = "Gender Filter"
//        obj1.price = "1.5$"
//        obj1.type = "genderFilter"
//        obj1.imageUrl = UIImage(named: "gender")
//        obj1.endDate = date
//        obj1.description = "buy 1 bottle so you dont have to wait for the automatic refill"
//        genderFilterArray.append(obj1)
//
//        let obj2:ShopItem = ShopItem()
//        obj2.firstColor = AppColors.grayXLight
//        obj2.secondColor = AppColors.grayXDark
//        obj2.title = "Gender Filter"
//        obj2.price = "5$"
//        obj2.type = "genderFilter"
//        obj2.endDate = date
//        obj2.imageUrl = UIImage(named: "gender")
//        obj2.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        genderFilterArray.append(obj2)
//
//        let obj3:ShopItem = ShopItem()
//        obj3.firstColor = AppColors.grayXLight
//        obj3.secondColor = AppColors.grayXDark
//        obj3.title = "Gender Filter"
//        obj3.price = "4.5$"
//        obj3.type = "genderFilter"
//        obj3.endDate = date
//        obj3.imageUrl = UIImage(named: "gender")
//        obj3.description = "buy 5 bottles so you dont have to wait for the automatic refill"
//        genderFilterArray.append(obj3)
//
//        let obj4:ShopItem = ShopItem()
//        obj4.firstColor = AppColors.grayXLight
//        obj4.secondColor = AppColors.grayXDark
//        obj4.title = "Gender Filter"
//        obj4.price = "1.5$"
//        obj4.type = "genderFilter"
//        obj4.endDate = date
//        obj4.imageUrl = UIImage(named: "gender")
//        obj4.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        genderFilterArray.append(obj4)
        
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
        
//        let date = Date().timeIntervalSince1970 * 1000 + (24*60*60*1000)
//
//        let obj1:ShopItem = ShopItem()
//        obj1.firstColor = AppColors.blueXDark
//        obj1.secondColor = AppColors.blueXLight
//        obj1.title = "3 Bottles"
//        obj1.type = "bottlesPackage"
//        obj1.price = "1.5$"
//        obj1.endDate = date
//        obj1.imageUrl = UIImage(named: "bottles2")
//
//        obj1.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        bottlrArray.append(obj1)
//
//        let obj2:ShopItem = ShopItem()
//        obj2.firstColor = AppColors.grayXLight
//        obj2.secondColor = AppColors.grayXDark
//        obj2.title = "3 Bottles"
//        obj2.price = "5$"
//        obj2.endDate = date
//        obj2.type = "bottlesPackage"
//        obj2.imageUrl = UIImage(named: "bottles")
//        obj2.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        bottlrArray.append(obj2)
//
//        let obj3:ShopItem = ShopItem()
//        obj3.firstColor = AppColors.grayXLight
//        obj3.secondColor = AppColors.grayXDark
//        obj3.title = "3 Bottles"
//        obj3.price = "4.5$"
//        obj3.endDate = date
//        obj3.type = "bottlesPackage"
//        obj3.imageUrl = UIImage(named: "bottles2")
//        obj3.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        bottlrArray.append(obj3)
//
//        let obj4:ShopItem = ShopItem()
//        obj4.firstColor = AppColors.grayXLight
//        obj4.secondColor = AppColors.grayXDark
//        obj4.title = "3 Bottles"
//        obj4.price = "1.5$"
//        obj4.endDate = date
//        obj4.type = "bottlesPackage"
//        obj4.imageUrl = UIImage(named: "bottles")
//        obj4.description = "buy 3 bottles so you dont have to wait for the automatic refill"
//        bottlrArray.append(obj4)
        
        self.shopItemsArray = bottlsArray.map{$0}
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
        let itemh = CGFloat(170)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ShopViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = self.shopItemsArray[indexPath.row]
        
        if bottlesButton.isSelected {
            
            let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.price ?? " ")") , preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                
                if obj.appleProduct != nil, let selectedItem = self.getProductById(itemId: obj.appleProduct!) {
                    
                    let pay = SKPayment(product: selectedItem)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(pay as SKPayment)
                    
                }
                // purchase request
                ApiManager.shared.purchaseItem(shopItem: obj, completionBlock: { (success, err, item) in
                    print ("res \(success)")
                    ApiManager.shared.getMe(completionBlock: { (success, err, user) in
                        self.dismiss(animated: true, completion: {})
                    })
                })
                
//                if let count = DataStore.shared.me?.bottlesLeftToThrowCount {
//                    DataStore.shared.me?.bottlesLeftToThrowCount = count + 1
//                }
            })
            alertController.addAction(ok)
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            var items:[InventoryItem] = [InventoryItem]()
            if genderFilterButton.isSelected {
                items = DataStore.shared.inventoryItems.filter({$0.type == .genderFilter})
            } else if countryFilterButton.isSelected {
                items = DataStore.shared.inventoryItems.filter({$0.type == .countryFilter})
            }
            
            if items.count == 0 {
                
                let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.price ?? " ")") , preferredStyle: .alert)
                let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                    
                    // flurry events
                    var prodType = "bottles"
                    if obj.type == ShopItemType.genderFilter {
                        prodType = "gender"
                    } else if obj.type == ShopItemType.countryFilter {
                        prodType = "country"
                    }
                    let logEventParams = ["prodType": prodType, "ProdName": obj.title_en ?? ""];
                    Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                    
                    // do the purchase
                    let inventoryItem = InventoryItem()
                    inventoryItem.isValid = true
                    inventoryItem.isConsumed = false
                    inventoryItem.shopItem = obj
                    inventoryItem.startDate = Date().timeIntervalSince1970
                    inventoryItem.endDate = Date().timeIntervalSince1970 + ((obj.validity ?? 1) * 60 * 60)
                    DataStore.shared.inventoryItems.append(inventoryItem)
                    
                    // flurry events, on purchase done
                    let logEventParams2 = ["prodType": prodType, "ProdName": obj.title_en ?? ""];
                    Flurry.logEvent(AppConfig.shop_purchase_complete, withParameters:logEventParams2);
                    
                    // purchase request
                    // purchase request
                    ApiManager.shared.purchaseItem(shopItem: obj, completionBlock: { (success, err, item) in
                        print ("res \(success)")
                        ApiManager.shared.getMe(completionBlock: { (success, err, user) in
                            self.dismiss(animated: true, completion: {})
                        })
                    })
                    
                })
                let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
                alertController.addAction(cancel)
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
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
        }
        let logEventParams = ["prodType": prodType];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
}

// MARK:- SKProductsRequestDelegate
extension ShopViewController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("product request")
        
        let myProduct = response.products
        
        for product in myProduct {
            
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            inAppPurchaseList.append(product)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        print("error")
    }
}

// MARK: - SKPaymentTransactionObserver
extension ShopViewController: SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        print("transactions restored")
//        for transaction in queue.transactions {
//
//            let t: SKPaymentTransaction = transaction
//
//            let prodID = t.payment.productIdentifier as String
//
//            if prodID == ShopItemID.Bottels3.rawValue {
//
//                if let count = DataStore.shared.me?.bottlesLeftToThrowCount {
//                    DataStore.shared.me?.bottlesLeftToThrowCount = count + 3
//                } else {
//
//                    DataStore.shared.me?.bottlesLeftToThrowCount = 3
//                }
//            } else if prodID == ShopItemID.Bottels5.rawValue {
//
//                if let count = DataStore.shared.me?.bottlesLeftToThrowCount {
//                    DataStore.shared.me?.bottlesLeftToThrowCount = count + 5
//                } else {
//
//                    DataStore.shared.me?.bottlesLeftToThrowCount = 5
//                }
//            }
//        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
//        for transaction: AnyObject in transactions {
//
//            let trans = transaction as! SKPaymentTransaction
//            print(trans.error)
//
//            switch trans.transactionState {
//
//            case .purchased:
//
//                print("buy ok, unlock IAP HERE")
//                print(p.productIdentifier)
//
//                let prodID = p.productIdentifier
//
//                if prodID == ShopItemID.Bottels3.rawValue {
//
//                    if let count = DataStore.shared.me?.bottlesLeftToThrowCount {
//                        DataStore.shared.me?.bottlesLeftToThrowCount = count + 3
//                    } else {
//
//                        DataStore.shared.me?.bottlesLeftToThrowCount = 3
//                    }
//                } else if prodID == ShopItemID.Bottels5.rawValue {
//
//                    if let count = DataStore.shared.me?.bottlesLeftToThrowCount {
//                        DataStore.shared.me?.bottlesLeftToThrowCount = count + 5
//                    } else {
//
//                        DataStore.shared.me?.bottlesLeftToThrowCount = 5
//                    }
//                }
//
//                switch prodID {
//                case "seemu.iap.removeads":
//                    print("remove ads")
//                    removeAds()
//                case "seemu.iap.addcoins":
//                    print("add coins to account")
//                    addCoins()
//                default:
//                    print("IAP not found")
//                }
//                queue.finishTransaction(trans)
//            case .failed:
//                print("buy error")
//                queue.finishTransaction(trans)
//                break
//            default:
//                print("Default")
//                break
//            }
//        }
    }
}

extension ShopViewController {
    
    func getProductById(itemId: String) -> SKProduct? {
        
        if self.inAppPurchaseList.count > 0 {
            
            for item in self.inAppPurchaseList {
                
                if item.productIdentifier == itemId {
                    
                    return item
                }
            }
        }
        return nil
    }
}
