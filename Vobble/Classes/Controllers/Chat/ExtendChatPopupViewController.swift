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
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTopTitle.text = "EXTEND_CHAT_POPUP_TITLE".localized
        self.lblUsername.text = self.username ?? ""
        
        self.chatCollectionView.register(UINib(nibName: "ExtendChatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExtendChatCollectionViewCellID")
        self.chatCollectionView.delegate = self
        self.chatCollectionView.dataSource = self
        
        layoutDesign()
        
        initChatArray()
        
        // Do any additional setup after loading the view.
        
        ApiManager.shared.requestShopItems(completionBlock: { (shores, error) in})
        
        //IAP Setup
        IAPManager.shared.delegate = self
        
        if !IAPManager.shared.isPaymentsReady() {
            self.chatItemsArray = []
        }
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
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtendChatCollectionViewCellID", for: indexPath) as! ExtendChatCollectionViewCell
        
        
        shopCell.configCell(shopItemObj: obj)
        
        return shopCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = self.chatItemsArray[indexPath.row]
        
        let alertController = UIAlertController(title: "", message: String(format: "BUY_ITEM_WARNING".localized, "\(obj.price ?? 0.0)") , preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { (alertAction) in
            
            if  obj.appleProduct != nil {
                self.showActivityLoader(true)
                self.popUpView.isUserInteractionEnabled = false
                if let selectedItem = IAPManager.shared.getProductById(itemId: obj.appleProduct!){
                    self.selectedProduct = obj
                    
                    IAPManager.shared.requestPaymentQueue(product: selectedItem, item: obj)
                    
                    // flurry events
                    let prodType = "extendChat"
                    
                    let logEventParams = ["prodType": prodType, "ProdName": self.selectedProduct.title_en ?? ""];
                    Flurry.logEvent(AppConfig.shop_purchase_click, withParameters:logEventParams);
                    
                }else{
                    self.showActivityLoader(false)
                    self.popUpView.isUserInteractionEnabled = true
                }
                
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .default,  handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
        

        // flurry events
        let prodType = "extendChat"
        
        let logEventParams = ["prodType": prodType];
        Flurry.logEvent(AppConfig.shop_select_product, withParameters:logEventParams);
        
    }
    
}


extension ExtendChatPopupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (popUpView.bounds.size.width - 16)
        let itemh = CGFloat(230)
        
        return CGSize(width: itemW / 3, height: itemh)
    }
}


// MARK:- IAPManagerDelegate
extension ExtendChatPopupViewController: IAPManagerDelegate {
    
    func didFailWithError(isAPIError: Bool, error: Error?, serverError: String?){
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
        FirebaseManager.shared.conversationRef.child(self.conversationId ?? "").child("startTime").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get conversation start time value
            let value = snapshot.value as? Double
            
            if let startTime = value {
                let extendTime = startTime + self.getExtendTime(self.selectedProduct.validity ?? 0.0)
                FirebaseManager.shared.conversationRef.child(self.conversationId ?? "").updateChildValues(["startTime" : extendTime])
                
                // Remove Old notification id and Register a new one
                ActionRemoveNotification.execute(id: self.conversationId ?? "")
                ActionRegisterNotification.execute(title: "CHAT_WARNING_TITLE".localized, body: "CHAT_WARNING_BODY".localized, id: self.conversationId ?? "", hours: (extendTime / 1000) - 7200)
            }
            
            

        }) { (error) in
            print(error.localizedDescription)
        }

        
        
        self.dismiss(animated: true, completion: {})

        self.showActivityLoader(false)
        self.popUpView.isUserInteractionEnabled = true
    }
    
}
