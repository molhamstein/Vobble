//
//  FiltersViewController.swift
//  Vobble
//
//  Created by Bayan on 3/11/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class FiltersViewController: AbstractController {
    
    @IBOutlet weak var filtrView: FilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension FiltersViewController: FilterViewDelegate {
    
    func getFilterInfo(gender: String, country: String) {
        
    }
}
