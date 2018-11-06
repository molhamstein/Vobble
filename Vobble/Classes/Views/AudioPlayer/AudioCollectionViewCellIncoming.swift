//
//  AudioCollectionViewCellIncomingCollectionViewCell.swift
//  Vobble
//
//  Created by Abd hayek on 11/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class AudioCollectionViewCellIncoming: JSQMessagesCollectionViewCellIncoming {

    @IBOutlet weak var audioProgressLabel: UILabel!
    @IBOutlet weak var audioProgressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    var audioDelegate : AudioCollectionViewCellIncomingDelegate!
    var index: Int!
    var data: Data!
    var url: URL!
    
    @IBAction func playButtonClicked(_ sender : UIButton) {
        audioDelegate.didPressPlayButtonIncoming(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.cellBackgroundView.layer.cornerRadius = 21
        self.indicatorView.isHidden = true
        self.backgroundColor = UIColor.clear
    }
    
}

protocol AudioCollectionViewCellIncomingDelegate : class {
    func didPressPlayButtonIncoming (_ cell : AudioCollectionViewCellIncoming)
    
}


