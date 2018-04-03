//
//  JSQCustomVideoItem.swift
//  Vobble
//
//  Created by Bayan on 4/1/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JSQCustomVideoMediaItem: JSQVideoMediaItem {
    
    var thumbImageView: UIImageView!
    var message: Message = Message()

    private var activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(message:Message, isOperator: Bool) {
        super.init()
        appliesMediaViewMaskAsOutgoing = (isOperator == false)
        thumbImageView = UIImageView()
        thumbImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 5
        thumbImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        activityIndicator?.frame = thumbImageView.frame
        thumbImageView.addSubview(activityIndicator!)
        
        self.message = message
        
    }
    
    func setThumbWithURL(url: URL) {
        
        if let videoUrl = message.videoUrl, videoUrl.hasPrefix("http://") {
            
            // thumb
            self.thumbImageView.sd_setShowActivityIndicatorView(true)
            self.thumbImageView.sd_setIndicatorStyle(.gray)
            self.thumbImageView.sd_setImage(with: URL(string:"http://104.217.253.15:9999/api/uploads/videos/download/1522664513030_IMG_0004.JPG"))
            activityIndicator?.removeFromSuperview()
        }
    }
    
    override func mediaView() -> UIView! {
        return thumbImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return thumbImageView.frame.size
    }
    
    
    
}
