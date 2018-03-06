//
//  HomeViewController.swift
//  BrainSocket Code base
//
//  Created by Molham Mahmoud on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class HomeViewController: AbstractController {
    
    // MARK: Properties
    @IBOutlet var ivSea: UIView!
    @IBOutlet var ivSky: UIImageView!
    @IBOutlet var ivClouds: UIImageView!
    @IBOutlet var ivSun: UIImageView!
    @IBOutlet var ivIsland: UIImageView!
    @IBOutlet var ivShore1Shore: UIImageView!
    @IBOutlet var ivShore2Shore: UIImageView!
    @IBOutlet var ivShore2Lovers: UIImageView!
    @IBOutlet var ivShore3Shore: UIImageView!
    
    var screenWidth: CGFloat = 0.0;
    var blockPageTransitions: Bool = false;
    var currentPageIndex :Int = 0;
    var isInitialized = false
    
    let seaParallaxSpeed :CGFloat = 0.3
    let shore1ParallaxSpeed :CGFloat = 1.0
    let shore2ParallaxSpeed :CGFloat = 1.0
    let island2ParallaxSpeed :CGFloat = 0.2
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable profile
        self.showNavProfileButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenWidth = self.view.frame.size.width;
    }
    
    /// Customize view
    override func customizeView() {
        // add here any viewes intialization code
        
        //add geture recognizer for swipping horizontally
        let panRec1 = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panRec1.delegate = self
        self.view.addGestureRecognizer(panRec1)
        
//        let panRec2 = UIPanGestureRecognizer.init(target: self, action: #selector(handleEdgeGestureRight))
//        panRec2.delegate = self
//        self.discoverControl?.twigListController.view.addGestureRecognizer(panRec2)
//        
//        let panRec3 = UIPanGestureRecognizer.init(target: self, action: #selector(handleEdgeGestureRight))
//        panRec3.delegate = self
//        vGestureReciever.addGestureRecognizer(panRec3)
    }
    
    
    @IBAction func throwBottlePressed(_ sender: UIButton) {
        [self .performSegue(withIdentifier: "homeRecrodSegue", sender: self)]
    }
    
    @IBAction func findBottlePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func myBottlesPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindRecordMedia(segue: UIStoryboardSegue) {
//        brands = (segue.source as! RecordMediaViewController).selectedBrands
//        type = (segue.source as! RecordMediaViewController).selectedType
//        loadWorkshops()
    }
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
        } else if gestureRecognizer.state == .changed {
            
            print("gest changing")
            if blockPageTransitions {
                print("gest blocked")
                return
            }
            
            let translation: CGPoint = gestureRecognizer.translation(in: view)
            //print("gest pan right \(fabs(translation.x/translation.y))")
            // min threshold for swipe
            if fabs(translation.x) < 30  || fabs(translation.y/translation.x) > 0.9{
                return
            }
            if translation.x < 0 {
                // swipping foreward to next screen
                if currentPageIndex == 0 {
                    //let transform = CGAffineTransform.identity.translatedBy(x: translation.x, y: 0)
                    let duration = 0.1
                    UIView.animate(withDuration: duration, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.seaParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore2ParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: translation.x * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                }
            } else {
                // swipping back to previews view
                if currentPageIndex == 0 {
                    // no action to take
                } else if currentPageIndex == 1 {
                    let transform = CGAffineTransform.identity.translatedBy(x: translation.x - self.screenWidth, y: 0)
                    UIView.animate(withDuration: 0.1, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * self.seaParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * self.shore2ParallaxSpeed, y: 0)
                        
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                } else {
                    
                }
            }
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            if blockPageTransitions {
                return
            }
            let translation: CGPoint = gestureRecognizer.translation(in: view)
            if (translation.x >= 100) {
                // moving back view
                if (currentPageIndex == 0) {
                    // no action to take
                    blockPageTransitions = false;
                } else if ( currentPageIndex == 1 ) {
                    self.goToMainShore()
                }
            } else if (translation.x <= -100) {
                // moving to next view
                if (currentPageIndex == 0) {
                    self.goToLoveShore()
                } else {
                    blockPageTransitions = false;
                    // no action to take
                }
            } else {
                // swipe distance was small
                // reset views to original locations
                if (currentPageIndex == 0) {
                    self.goToMainShore()
                } else if ( currentPageIndex == 1 ) {
                    self.goToLoveShore()
                }
            }
        }
    }
    
    
    func goToMainShore() {
        
        if blockPageTransitions {
            return
        }
        
        let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        UIView.animate(withDuration: 0.5, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.ivSea.transform = CGAffineTransform.identity
            self.ivIsland.transform = CGAffineTransform.identity
            self.ivShore1Shore.transform = CGAffineTransform.identity
            self.ivShore2Shore.transform = CGAffineTransform.identity
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 0
            self.blockPageTransitions = false
        })
        
//        UIView.animate(withDuration: 0.7, delay:0.0, usingSpringWithDamping:0.7, initialSpringVelocity:3, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.momentsControl?.view.transform = transform
//            self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: -self.screenWidth * 0.4, y: 0)
//        }, completion: {(finished: Bool) in
//        })
//        
//        // adding a different delay
//        UIView.animate(withDuration: 0.5, delay:0.3, usingSpringWithDamping:0.75, initialSpringVelocity:2, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.momentsControl?.ivlike.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
//        }, completion: {(finished: Bool) in
//        })
//        
//        // adding a different delay
//        UIView.animate(withDuration: 0.5, delay:0.5, usingSpringWithDamping:0.75, initialSpringVelocity:2, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.momentsControl?.ivIgnore.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 0)
//        }, completion: {(finished: Bool) in
//            
//        })
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(9 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
//            snackbar.dismiss()
//        }
//        dispatch_main_after(0.5) {
//            self.currentPageIndex = 0
//            self.blockPageTransitions = false
//        }
    }
    
    func goToLoveShore() {
        if blockPageTransitions {
            return
        }
        
        //let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        UIView.animate(withDuration: 0.5, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.seaParallaxSpeed), y: 0)
            self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.island2ParallaxSpeed), y: 0)
            self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore1ParallaxSpeed), y: 0)
            self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore2ParallaxSpeed), y: 0)
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 1
            self.blockPageTransitions = false
        })
    }
    
    func goToFadFedShore() {
        
    }
}

extension HomeViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

