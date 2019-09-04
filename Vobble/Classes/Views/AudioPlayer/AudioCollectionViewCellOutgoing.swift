//
//  AudioCollectionViewCell.swift
//  Vobble
//
//  Created by ِAbd hayek on 11/3/18.
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
    var audioDuration: Double?
    
    @IBAction func playButtonClicked(_ sender : UIButton) {
        audioDelegate.didPressPlayButtonOutgoing(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.audioProgressLabel.text = String(format: "%02d", Int(self.audioDuration ?? 0.0))
        self.cellBackgroundView.layer.cornerRadius = 21
        self.indicatorView.isHidden = true
        self.backgroundColor = UIColor.clear
        self.cellBottomLabel.textAlignment = .center
        
    }
    
    func configureCell(_ audioItem: JSQCustomAudioMediaItem, index: Int) {
        self.index = index
        self.url = audioItem.audioUrl
        self.data = audioItem.audioData
        self.audioDuration = audioItem.audioDuration
        
        self.audioProgressLabel.text = String(format: "%02d", Int(self.audioDuration ?? 0.0))
        
        if (audioItem.audioUrl?.isValidUrl())! {
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            self.playButton.isHidden = false
        }else{
            self.indicatorView.startAnimating()
            self.indicatorView.isHidden = false
            self.playButton.isHidden = true
        }

    }
}

protocol AudioCollectionViewCellOutgoingDelegate : class {
    func didPressPlayButtonOutgoing (_ cell : AudioCollectionViewCellOutgoing)
    
}
