//
//  AudioCollectionViewCell.swift
//  Vobble
//
//  Created by Emessa Group on 11/3/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class AudioCollectionViewCellOutgoing: JSQMessagesCollectionViewCellOutgoing {

    @IBOutlet weak var audioProgressLabel: UILabel!
    @IBOutlet weak var audioProgressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    var audioDelegate : AudioCollectionViewCellOutgoingDelegate!
    var index: Int!
    var data: Data!
    var url: URL!
    
    @IBAction func playButtonClicked(_ sender : UIButton) {
        audioDelegate.didPressPlayButtonOutgoing(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.cellBackgroundView.layer.cornerRadius = 21
        self.indicatorView.isHidden = true
        self.backgroundColor = UIColor.clear
        
    }
    

}

protocol AudioCollectionViewCellOutgoingDelegate : class {
    func didPressPlayButtonOutgoing (_ cell : AudioCollectionViewCellOutgoing)
    
}
