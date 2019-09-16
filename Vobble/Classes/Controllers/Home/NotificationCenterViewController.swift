//
//  NotificationCenterViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/15/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class NotificationCenterViewController: AbstractController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: "NotificationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NotificationCollectionViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCollectionViewCell", for: indexPath) as! NotificationCollectionViewCell
        
        if indexPath.row == 3 {
            cell.lblDescription.text = "Our mission is to get you from not knowing anything about programming and Android development, to building top-notch, scalable applications in no time. Our mission is to get you from not knowing anything about programming and Android development, to building top-notch, scalable applications in no time. Our mission is to get you from not knowing anything about programming and Android development, to building top-notch, scalable applications in no time. Our mission is to get you from not knowing anything about programming and Android development, to building top-notch, scalable applications in no time. Our mission is to get you from not knowing anything about programming and Android development, to building top-notch, scalable applications in no time. "
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 16, height: 50)
    }
}
