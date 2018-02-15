//
//  AbstractNibView.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 19/10/16.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
// Usage: Subclass your UIView from NibLoadView to automatically load a xib with the same name as your class
class AbstractNibView: UIView {
    // MARK: Properties
    @IBOutlet weak var view: UIView!
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
