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
    
    var containerView: UIView!
    var thumbImageView: UIImageView!
    var playIconImageView: UIImageView!
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
        containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 5
        containerView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        thumbImageView = UIImageView()
        thumbImageView.frame = containerView.frame
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 5
        thumbImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        thumbImageView.contentMode = .scaleAspectFill
        containerView.addSubview(thumbImageView)
        
        activityIndicator?.frame = thumbImageView.frame
        activityIndicator?.activityIndicatorView.isHidden = false
        activityIndicator?.activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicator!)
        
        playIconImageView = UIImageView()
        playIconImageView.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        playIconImageView.image = UIImage(named: "playVideoIcon")
        //playIconImageView.backgroundColor = UIColor.white
        containerView.addSubview(playIconImageView)
        
        self.message = message
    }
    
    func setThumbWithURL(url: URL) {
        
        if let videoUrl = message.videoUrl, (videoUrl.hasPrefix("http://") || videoUrl.hasPrefix("https://"))  {
            
            // thumb
            self.thumbImageView.sd_setShowActivityIndicatorView(true)
            self.thumbImageView.sd_setIndicatorStyle(.white)
            activityIndicator?.removeFromSuperview()
            thumbImageView.contentMode = .scaleAspectFill
            if let thumbStrUrl = message.thumbUrl, let thumbUrl = URL(string:thumbStrUrl) {
                self.thumbImageView.sd_setImage(with: thumbUrl)
                //self.thumbImageView.backgroundColor = UIColor.blue
            } else {
                self.thumbImageView.image = nil
                //self.thumbImageView.backgroundColor = UIColor.clear
            }
        }
    }
    
    override func mediaView() -> UIView! {
        return containerView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return thumbImageView.frame.size
    }
    
    
    
}
