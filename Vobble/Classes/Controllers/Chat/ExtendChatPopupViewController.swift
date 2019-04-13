//
//  ExtendChatPopupViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 4/7/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

/*
 TO DO:
1- Add subtitles to strings files
*/
class ExtendChatPopupViewController: AbstractController {

    @IBOutlet weak var lblTopTitle: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTopTitle.text = "EXTEND_CHAT_TITLE".localized
        
        initBottleArray()
        chatCollectionView.reloadData()
        // Do any additional setup after loading the view.
        
        ApiManager.shared.requestShopItems(completionBlock: { (shores, error) in})
        
        //IAP Setup
        IAPManager.shared.delegate = self
        
        if !IAPManager.shared.isPaymentsReady() {
            self.chatItemsArray = []
        }
    }

    private func initBottleArray() {
        var bottlsArray:[ShopItem] = [ShopItem]()
        bottlsArray = DataStore.shared.shopItems.filter({$0.type == .bottlesPack})
        
        
        self.chatItemsArray = bottlsArray.map{$0}
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
        
        let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCellID", for: indexPath) as! ShopCollectionViewCell
        
        
        shopCell.configCell(shopItemObj: obj)
        
        return shopCell
    }
    
    
}


extension ExtendChatPopupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (popUpView.bounds.size.width)
        let itemh = CGFloat(170)
        
        return CGSize(width: itemW, height: itemh)
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
        self.dismiss(animated: true, completion: {})
        
        self.showActivityLoader(false)
        self.popUpView.isUserInteractionEnabled = true
    }
    
}
