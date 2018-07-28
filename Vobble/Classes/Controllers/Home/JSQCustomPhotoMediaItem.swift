//
//  JSQCustomPhotoMediaItem.swift
//  Vobble
//
//  Created by Bayan on 4/1/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JSQCustomPhotoMediaItem: JSQPhotoMediaItem {
    
    var containerView: UIView!
    var asyncImageView: UIImageView!
    var message: Message = Message()
    
    private var activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(message:Message, isOperator: Bool) {
        super.init()
        appliesMediaViewMaskAsOutgoing = (isOperator == false)
        
        containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 5
        containerView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 5
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        containerView.addSubview(asyncImageView)
        
        activityIndicator?.frame = asyncImageView.frame
        activityIndicator?.activityIndicatorView.isHidden = false
        activityIndicator?.activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicator!)
        
        self.message = message
    }
    
    func setImageWithURL() {
        
        if let photoUrl = self.message.photoUrl, (photoUrl.hasPrefix("http://") || photoUrl.hasPrefix("https://")) {
            
            self.asyncImageView.sd_setShowActivityIndicatorView(true)
            self.asyncImageView.sd_setIndicatorStyle(.white)
            self.asyncImageView.sd_setImage(with: URL(string:photoUrl))
            self.asyncImageView.contentMode = .scaleAspectFill
            activityIndicator?.removeFromSuperview()
        }
    }
    
    override func mediaView() -> UIView! {
        return containerView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
