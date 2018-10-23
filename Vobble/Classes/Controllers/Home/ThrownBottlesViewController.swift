//
//  ThrownBottlesViewController.swift
//  Vobble
//
//  Created by Emessa Group on 10/22/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit

class ThrownBottlesViewController: AbstractController {
    
    @IBOutlet weak var bottleCollectionView: UICollectionView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    
    // empty placeholder
    @IBOutlet weak var emptyPlaceHolderView: UIView!
    @IBOutlet weak var emptyPlaceHolderLabel: UILabel!
    
    var bottles : [Bottle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation bar
        self.navigationView.viewcontroller = self
        self.navigationView.title = "MY_BOTTLES_TITLE".localized
        
        // Setup collection view
        self.bottleCollectionView.register(UINib(nibName: "ThrownBottleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ThrownBottleCollectionViewCell")
        self.bottleCollectionView.dataSource = self
        self.bottleCollectionView.delegate = self
        
        emptyPlaceHolderView.isHidden = true
        emptyPlaceHolderLabel.font = AppFonts.normal
        emptyPlaceHolderLabel.text = "MY_BOTTLES_EMPTY_PLACEHOLDER".localized
        
        // Get thrown bottles
        ApiManager.shared.requestThwonBottles(completionBlock: { bottles , error in
            if error == nil {
                self.bottles = DataStore.shared.thrownBottles
                
                if self.bottles.count > 0 {
                    self.emptyPlaceHolderView.isHidden = true
                    self.bottleCollectionView.reloadData()
                }else {
                    self.emptyPlaceHolderView.isHidden = false
                }
            }else{
                self.emptyPlaceHolderView.isHidden = false
            }
        })
    }
    

}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension ThrownBottlesViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bottles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThrownBottleCollectionViewCell", for: indexPath) as! ThrownBottleCollectionViewCell
        
        let bottle = self.bottles[indexPath.row]
        
        cell.configCell(bottle: bottle)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bottle = self.bottles[indexPath.row]
        
        if let videoUrl = bottle.file {
            let previewControl = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "PreviewMediaControl") as! PreviewMediaControl
            previewControl.from = .chatView
            previewControl.type = .VIDEO
            previewControl.videoUrl = NSURL(string: videoUrl)!
            
            present(previewControl, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ThrownBottlesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = ((self.bottleCollectionView.frame.width / 2) - 2)
        let itemh = itemW 
        
        return CGSize(width: itemW, height: itemh)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    }
}
