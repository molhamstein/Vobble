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
    
    var asyncImageView: UIImageView!
    private var activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(withURL url: URL, imageSize: CGSize, isOperator: Bool) {
        super.init()
        appliesMediaViewMaskAsOutgoing = (isOperator == false)
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 5
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        activityIndicator?.frame = asyncImageView.frame
        asyncImageView.addSubview(activityIndicator!)
        
    }
    
    func setImageWithURL(url: URL) {
        
        if url.absoluteString.hasPrefix("http://") {
            
            self.asyncImageView.sd_setShowActivityIndicatorView(true)
            self.asyncImageView.sd_setIndicatorStyle(.gray)
            self.asyncImageView.sd_setImage(with: url)
            activityIndicator?.removeFromSuperview()
        }
    }
    
    
    override func mediaView() -> UIView! {
        return asyncImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}