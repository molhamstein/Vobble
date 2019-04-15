//
//  IAPManager.swift
//  Vobble
//
//  Created by Abd Hayek on 4/5/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import Flurry_iOS_SDK

@objc protocol IAPManagerDelegate: class {
    @objc optional func didPaymentCompleted()
    @objc optional func didFailWithError(isAPIError: Bool, error: Error?, serverError: String?)
}

class IAPManager: NSObject {
    
    static public let shared = IAPManager()
    
    public var delegate: IAPManagerDelegate?
    
    private var request: SKProductsRequest?
    
    fileprivate var inAppPurchaseList = [SKProduct]()
    
    fileprivate var selectedItem: ShopItem?
    
    private override init() {
        super.init()
    }
    
    public func clearCachedTransaction() {
        for transaction: SKPaymentTransaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    public func isPaymentsReady() -> Bool {
        
        clearCachedTransaction()
        
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(array: ShopItemID.getListId())
            request = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request?.delegate = self
            request?.start()
            
        } else {
            print("please enable IAPS")
        }
        
        return SKPaymentQueue.canMakePayments()
    }
    
    public func cancel(){
        request?.cancel()
    }
    
    public func getProductById(itemId: String) -> SKProduct? {
        
        if self.inAppPurchaseList.count > 0 {
            for item in self.inAppPurchaseList {
                if item.productIdentifier == itemId {
                    return item
                }
            }
        }
        
        return nil
    }
    
    public func requestPaymentQueue(product: SKProduct, item: ShopItem){
        selectedItem = item
        
        let pay = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay)
    }
    
    fileprivate func finishTransaction(_ queue: SKPaymentQueue , _ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
        queue.remove(self)
        
    }
}

extension IAPManager : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                
            case .purchasing :
                print("purchasing")
                
            case .purchased:

                //let SUBSCRIPTION_SECRET = "yourpasswordift"
                let receiptPath = Bundle.main.appStoreReceiptURL?.path
                var base64encodedReceipt: String?;
                if FileManager.default.fileExists(atPath: receiptPath!){
                    var receiptData:NSData?
                    do {
                        receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
                    } catch {
                        print("ERROR: " + error.localizedDescription)
                    }
                    
                    base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
                    //print("base64encodedReceipt: " + base64encodedReceipt!)
                }
                
                if let encodedRecept = base64encodedReceipt, let transactionId = transaction.transactionIdentifier {
                    // purchase request
                    ApiManager.shared.purchaseItem(shopItem: self.selectedItem!, recienptBase64String: encodedRecept, transactionId: transactionId,  completionBlock: {(success, err, item) in
                        if success {
                            
                            // Bottles Purchase
                            if self.selectedItem?.type == ShopItemType.bottlesPack {
                                ApiManager.shared.getMe(completionBlock: { (success, err, user) in
                                    self.delegate?.didPaymentCompleted?()
                                })
                            }else if self.selectedItem?.type == ShopItemType.ExtendChat {
                                self.delegate?.didPaymentCompleted?()
                                
                            } else {
                                // flurry events
                                var prodType = "bottles"
                                if self.selectedItem?.type == ShopItemType.genderFilter {
                                    prodType = "gender"
                                } else if self.selectedItem?.type == ShopItemType.countryFilter {
                                    prodType = "country"
                                }
                                
                                // do the purchase
                                let inventoryItem = InventoryItem()
                                inventoryItem.isValid = true
                                inventoryItem.isConsumed = false
                                inventoryItem.shopItem = self.selectedItem!
                                inventoryItem.startDate = Date().timeIntervalSince1970
                                inventoryItem.endDate = Date().timeIntervalSince1970 + ((self.selectedItem?.validity ?? 1) * 60 * 60)
                                DataStore.shared.inventoryItems.append(inventoryItem)
                                
                                // flurry events, on purchase done
                                let logEventParams2 = ["prodType": prodType, "ProdName": self.selectedItem?.title_en ?? ""];
                                Flurry.logEvent(AppConfig.shop_purchase_complete, withParameters:logEventParams2);
                                
                                self.delegate?.didPaymentCompleted?()
                            }
                        }else{
                            self.delegate?.didFailWithError?(isAPIError: true, error: nil, serverError: err?.errorName)
                            
                        }
                        
                    })
                }
                
                
                
                finishTransaction(queue, transaction)
                
            case .failed:
                print("buy error")
                
                finishTransaction(queue, transaction)
                
                self.delegate?.didFailWithError?(isAPIError: false, error: transaction.error, serverError: nil)
                
            case .deferred :
                print("deferred")
                finishTransaction(queue, transaction)
                
            default:
                print("Default")
                finishTransaction(queue, transaction)
                
                
            }
        }
    }
}


extension IAPManager : SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for faild in response.invalidProductIdentifiers {
            print(faild)
        }
        for product in response.products {
            print(product.productIdentifier)
            inAppPurchaseList.append(product)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.delegate?.didFailWithError?(isAPIError: false, error: error, serverError: nil)
    }
}
