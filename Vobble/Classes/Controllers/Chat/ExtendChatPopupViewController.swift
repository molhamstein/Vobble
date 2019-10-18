//
//  ExtendChatPopupViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 4/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import FirebaseDatabase

/*
 TO DO:
1- Add subtitles to strings files
*/
class ExtendChatPopupViewController: AbstractController {

    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var popUpView: UIView!
    
    private var _chatItemsArray:[ShopItem] = [ShopItem]()
    fileprivate var chatItemsArray: [ShopItem] {
        set {
            _chatItemsArray = newValue
            chatCollectionView.reloadData()
        }
        get {
            if(_chatItemsArray.isEmpty){
                _chatItemsArray = [ShopItem]()
            }
            return _chatItemsArray
        }
    }
    
    var selectedProduct : ShopItem!
    
    var conversationId: String?
    
    var conversation: Conversation?
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTopTitle.text = String.init(format: "EXTEND_CHAT_POPUP_TITLE".localized, "")
        self.lblTopTitle.font = AppFonts.xBigBold
        self.lblUsername.text = self.username ?? ""
        
        self.chatCollectionView.register(UINib(nibName: "OutsideShopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OutsideShopCollectionViewCell")
        self.chatCollectionView.delegate = self
        self.chatCollectionView.dataSource = self
        
        layoutDesign()
        
        initChatArray()
        
        // Do any additional setup after loading the view.
        
        ApiManager.shared.requestShopItems(completionBlock: { (items, error) in})
        
        //IAP Setup
        //IAPManager.shared.delegate = self
        //IAPManager.shared.currentViewController = self
        
//        if !IAPManager.shared.isPaymentsReady() {
//            self.chatItemsArray = []
//        }
        
        self.chatCollectionView.isScrollEnabled = true

    }

    private func initChatArray() {
        var chatsArray:[ShopItem] = [ShopItem]()
        chatsArray = DataStore.shared.shopItems.filter({$0.type == .ExtendChat})
        
        
        self.chatItemsArray = chatsArray.map{$0}
        
        chatCollectionView.reloadData()
    }
    
    private func layoutDesign(){
        self.popUpView.layer.cornerRadius = 20
        self.popUpView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.popUpView.layer.borderWidth = 0.5
        self.popUpView.layer.masksToBounds = true
        self.popUpView.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        self.popUpView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
    }
    
    fileprivate func getExtendTime(_ validity: Double) -> Double {
        return validity * 60 * 60 * 1000
    }
    
    
    
    @IBAction func close(_ sender: Any){
        IAPManager.shared.cancel()
        
        self.dismiss(animated: true, completion: nil)
    }
}


extension ExtendChatPopupViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.chatItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let obj = self.chatItemsArray[indexPath.row]
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutsideShopCollectionViewCell", for: indexPath) as! OutsideShopCollectionViewCell
        
        
        shopCell.configCell(shopItemObj: obj)
        
        return shopCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = self.chatItemsArray[indexPath.row]
        if (DataStore.shared.me?.pocketCoins ?? 0) >= (obj.priceCoins ?? 0) {
            
            let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.priceCoins ?? 0) " + "COINS".localized) , preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
                
                self.selectedProduct = obj
                
                // flurry events
                let logEventParams = ["prodType": "extendChat", "ProdName": self.selectedProduct.title_en ?? ""];
                Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                
                self.showActivityLoader(true)
                
                ApiManager.shared.purchaseItemByCoins(shopItem: obj, completionBlock: {isSuccess, error, shopItem in
                    if error == nil {
                        DataStore.shared.me?.pocketCoins! -= (obj.priceCoins ?? 0)
                        
                        self.didPaymentCompleted()
                        
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
        let logEventParams = ["prodType": "extendChat"];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
        
    }
    
}


extension ExtendChatPopupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (popUpView.bounds.size.width - 16)
        let itemh = UIScreen.main.bounds.height > 570 ? CGFloat(210) : CGFloat(190)
        
        return CGSize(width: itemW / 3, height: itemh)
    }
}


// MARK:- IAPManagerDelegate
extension ExtendChatPopupViewController: IAPManagerDelegate {
    
    func didFailWithError(isAPIError: Bool, error: Error?, serverError: String?){
        self.showActivityLoader(false)
        self.popUpView.isUserInteractionEnabled = true
        
        if isAPIError {
            if let err = serverError {
                let alert = UIAlertController(title: "GLOBAL_ERROR_TITLE".localized, message: err , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
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
        FirebaseManager.shared.conversationRef.child(self.conversationId ?? "").child("finishTime").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get conversation start time value
            let value = snapshot.value as? Double
            
            if let expiryTime = value {
                let extendTime = expiryTime + self.getExtendTime(self.selectedProduct.validity ?? 0.0)
                FirebaseManager.shared.conversationRef.child(self.conversationId ?? "").updateChildValues(["finishTime" : extendTime])
                
                self.conversation?.finishTime = extendTime
                
                ActionRegisterNotification.execute(conversation: self.conversation)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }

        self.dismiss(animated: true, completion: {})

        self.showActivityLoader(false)
        self.popUpView.isUserInteractionEnabled = true
    }
    
}
