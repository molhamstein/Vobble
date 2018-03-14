//
//  ConversationViewController.swift
//  Vobble
//
//  Created by Bayan on 3/12/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class ConversationViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet weak var bottleCollectionView: UICollectionView!
    @IBOutlet weak var waveSubView: WaveView!
    
    
    fileprivate var currentUser: AppUser = AppUser()
    fileprivate var filteredConvArray: [Conversation] = [Conversation]()
    fileprivate var searchText: UITextField?
    fileprivate var searchString: String = ""
    public var tap: tapOption = .myBottles
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationCollectionViewCellID")
        
        self.bottleCollectionView.register(UINib(nibName: "ConversationCollectionViewHeader",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "conversationCollectionViewHeaderID")
        
        self.initBottleArray()
    }
    
    override func viewDidLayoutSubviews() {
        waveSubView.awakeFromNib()
        waveSubView.showWave()
    }
    
    private func initBottleArray() {
        var convArray:[Conversation] = [Conversation]()
        var repliesArray:[Conversation] = [Conversation]()
        
        let obj1:Conversation = Conversation()
        obj1.user2 = AppUser()
        obj1.user2?.firstColor = AppColors.blueXDark
        obj1.user2?.secondColor = AppColors.blueXLight
        obj1.user2?.firstName = "Sundar Pitchai"
        obj1.timeLeft = "02:04:12"
        obj1.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj1.user2?.country = "USA"
        convArray.append(obj1)
        
       
        let obj2:Conversation = Conversation()
        obj2.user2 = AppUser()
        obj2.user2?.firstColor = AppColors.grayXLight
        obj2.user2?.secondColor = AppColors.grayXDark
        obj2.user2?.firstName = "Sundar Pitchai2"
        obj2.timeLeft = "02:04:12"
        obj2.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj2.user2?.country = "USA"
        convArray.append(obj2)
        
        let obj3:Conversation = Conversation()
        obj3.user2 = AppUser()
        obj3.user2?.firstColor = AppColors.blueXDark
        obj3.user2?.secondColor = AppColors.blueXLight
        obj3.user2?.firstName = "Sundar Pitchai"
        obj3.timeLeft = "02:04:12"
        obj3.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj3.user2?.country = "USA"
        convArray.append(obj3)
        
        let obj4:Conversation = Conversation()
        obj4.user2 = AppUser()
        obj4.user2?.firstColor = AppColors.grayXDark
        obj4.user2?.secondColor = AppColors.grayXLight
        obj4.user2?.firstName = "Sundar Pitchai"
        obj4.timeLeft = "02:04:12"
        obj4.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj4.user2?.country = "USA"
        convArray.append(obj4)
        
        let obj5:Conversation = Conversation()
        obj5.user2 = AppUser()
        obj5.user2?.firstColor = AppColors.blueXLight
        obj5.user2?.secondColor = AppColors.blueXDark
        obj5.user2?.firstName = "Sundar Pitchai"
        obj5.timeLeft = "02:04:12"
        obj5.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj5.user2?.country = "USA"
        convArray.append(obj5)
        
        let obj6:Conversation = Conversation()
        obj6.user2 = AppUser()
        obj6.user2?.firstColor = AppColors.grayXLight
        obj6.user2?.secondColor = AppColors.grayXDark
        obj6.user2?.firstName = "Sundar Pitchai"
        obj6.timeLeft = "02:04:12"
        obj6.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj6.user2?.country = "USA"
        convArray.append(obj6)
        
        let obj7:Conversation = Conversation()
        obj7.user2 = AppUser()
        obj7.user2?.firstColor = AppColors.blueXDark
        obj7.user2?.secondColor = AppColors.blueXLight
        obj7.user2?.firstName = "Sundar Pitchai"
        obj7.timeLeft = "02:04:12"
        obj7.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj7.user2?.country = "USA"
        convArray.append(obj7)
        
        currentUser.conversationArray = convArray.map{$0}
        
        //==========================================
        
        let obj11:Conversation = Conversation()
        obj11.user2 = AppUser()
        obj11.user2?.firstColor = AppColors.blueXDark
        obj11.user2?.secondColor = AppColors.blueXLight
        obj11.user2?.firstName = "soso koko"
        obj11.timeLeft = "02:04:12"
        obj11.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj11.user2?.country = "USA"
        repliesArray.append(obj11)
        
        
        let obj22:Conversation = Conversation()
        obj22.user2 = AppUser()
        obj22.user2?.firstColor = AppColors.grayXLight
        obj22.user2?.secondColor = AppColors.grayXDark
        obj22.user2?.firstName = "lolo koko"
        obj22.timeLeft = "02:04:12"
        obj22.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj22.user2?.country = "USA"
        repliesArray.append(obj22)
        
        let obj33:Conversation = Conversation()
        obj33.user2 = AppUser()
        obj33.user2?.firstColor = AppColors.blueXDark
        obj33.user2?.secondColor = AppColors.blueXLight
        obj33.user2?.firstName = "dodo koko2"
        obj33.timeLeft = "02:04:12"
        obj33.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj33.user2?.country = "USA"
        repliesArray.append(obj33)
        
        let obj44:Conversation = Conversation()
        obj44.user2 = AppUser()
        obj44.user2?.firstColor = AppColors.grayXDark
        obj44.user2?.secondColor = AppColors.grayXLight
        obj44.user2?.firstName = "soso koko2"
        obj44.timeLeft = "02:04:12"
        obj44.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj44.user2?.country = "USA"
        repliesArray.append(obj44)
        
        let obj55:Conversation = Conversation()
        obj55.user2 = AppUser()
        obj55.user2?.firstColor = AppColors.blueXLight
        obj55.user2?.secondColor = AppColors.blueXDark
        obj55.user2?.firstName = "koko koko"
        obj55.timeLeft = "02:04:12"
        obj55.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj55.user2?.country = "USA"
        repliesArray.append(obj55)
        
        let obj66:Conversation = Conversation()
        obj66.user2 = AppUser()
        obj66.user2?.firstColor = AppColors.grayXLight
        obj66.user2?.secondColor = AppColors.grayXDark
        obj66.user2?.firstName = "toto koko"
        obj66.timeLeft = "02:04:12"
        obj66.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj66.user2?.country = "USA"
        repliesArray.append(obj66)
        
        let obj77:Conversation = Conversation()
        obj77.user2 = AppUser()
        obj77.user2?.firstColor = AppColors.blueXDark
        obj77.user2?.secondColor = AppColors.blueXLight
        obj77.user2?.firstName = "toto koko2"
        obj77.timeLeft = "02:04:12"
        obj77.user2?.imageUrl = UIImage(named: "user_placeholder")
        obj77.user2?.country = "USA"
        repliesArray.append(obj77)
        
        currentUser.repliesArray = repliesArray.map{$0}
        
    }
    
}
// MARK: - UICollectionViewDataSource
extension ConversationViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filteredConvArray.count > 0 {
            // string contains non-whitespace characters
            return self.filteredConvArray.count
        } else if tap == .myBottles {
            return self.currentUser.conversationArray.count
        }
        
       return self.currentUser.repliesArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let convCell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationCollectionViewCellID", for: indexPath) as! ConversationCollectionViewCell

        if self.filteredConvArray.count > 0 {
            let obj = self.filteredConvArray[indexPath.row]
            convCell.configCell(convObj: obj )
        } else if tap == .myBottles {
            let obj = self.currentUser.conversationArray[indexPath.row]
            convCell.configCell(convObj: obj)
        } else if tap == .myReplies {
            let obj = self.currentUser.repliesArray[indexPath.row]
            convCell.configCell(convObj: obj)
        }
        
        return convCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "conversationCollectionViewHeaderID", for: indexPath) as! ConversationCollectionViewHeader
        
        headerView.searchTetField.text = searchString
        headerView.searchTetField.delegate = self
        headerView.convVC = self
        
        self.searchText =  headerView.searchTetField
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.bottleCollectionView.bounds.width, height: 210)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemW = (UIScreen.main.bounds.size.width)
        let itemh = CGFloat(140)
        
        return CGSize(width: itemW, height: itemh)
    }
}

// MARK: - UICollectionViewDelegate
extension ConversationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
}

// MARK: - textfield delegate
extension ConversationViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string1 = string
        let string2 = (self.searchText?.text)!

        if string.characters.count > 0 { // if it was not delete character
            searchString = string2 + string1
        }
        else if string2.characters.count > 0 { // if it was a delete character
            
            searchString = String(string2.characters.dropLast())
        }
        
        filteredConvArray = currentUser.conversationArray.filter{(($0.user2?.firstName)!.lowercased().contains(searchString.lowercased()))}
        
        print(filteredConvArray.count)
        
        bottleCollectionView.reloadData()
        
        return true
    }
    
    
}

