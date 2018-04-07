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
    @IBOutlet var ivMountains: UIImageView!
    @IBOutlet var ivSun: UIImageView!
    @IBOutlet var ivIsland: UIImageView!
    @IBOutlet var ivShore1Shore: UIImageView!
    @IBOutlet var ivShore2Shore: UIImageView!
    @IBOutlet var shore2Lovers: UIView!
    @IBOutlet var ivShore3Shore: UIImageView!
    @IBOutlet var shore3Friends: UIView!
    @IBOutlet weak var navigationView: VobbleNavigationBar!
    @IBOutlet weak var filterViewOverlay: UIView!
    @IBOutlet weak var filterView: FilterView!
    
    // throw
    @IBOutlet weak var vThrowBtnContainer: UIView!
    @IBOutlet weak var lblThrowBtn: UILabel!
    @IBOutlet weak var ivThrowBtn: UIImageView!
    // my bottles
    @IBOutlet weak var vMyBottlesBtnContainer: UIView!
    @IBOutlet weak var lblMyBottlesBtn: UILabel!
    @IBOutlet weak var ivMyBottlesBtn: UIImageView!
    // find
    @IBOutlet weak var vFindBtnContainer: UIView!
    @IBOutlet weak var lblFindBtn: UILabel!
    @IBOutlet weak var ivFindBtn: UIImageView!
    
    // GIF images
    @IBOutlet var ivShore2Girl: UIImageView!
    @IBOutlet var ivShore3Girl1: UIImageView!
    @IBOutlet var ivShore3Girl2: UIImageView!
    @IBOutlet var ivShore3Boy: UIImageView!
    
    var screenWidth: CGFloat = 0.0;
    var blockPageTransitions: Bool = false;
    var currentPageIndex :Int = 0;
    var isInitialized = false
    
    let seaParallaxSpeed :CGFloat = 0.3
    let sunParallaxSpeed :CGFloat = 0.1
    let cloudsParallaxSpeed :CGFloat = 0.2
    let mountainsParallaxSpeed :CGFloat = 0.25
    let island2ParallaxSpeed :CGFloat = 0.3
    let shore1ParallaxSpeed :CGFloat = 1.0
    let shore2ParallaxSpeed :CGFloat = 1.0
    let shore3ParallaxSpeed :CGFloat = 1.0
    let loversParallaxSpeed :CGFloat = 1.0
    let friendsParallaxSpeed :CGFloat = 1.0
    
    // bottle animations 
    @IBOutlet var ivFindBottle: UIImageView!
    @IBOutlet var ivThrowBottle: UIImageView!
    
    var introAnimationDone: Bool = false
    var filterViewVisible = false
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable profile
        self.showNavProfileButton = true
        self.navigationView.viewcontroller = self
        self.filterView.delegate = self
        
        // hide filters View by default
        self.filterView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.filterView.frame.height - 50)
        self.filterViewOverlay.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenWidth = self.view.frame.size.width;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // animate view in
        if !introAnimationDone {
            ivClouds.animateIn(mode: .animateInFromTop, delay: 0.2)
            ivMountains.animateIn(mode: .animateInFromTop, delay: 0.3)
            ivSun.animateIn(mode: .animateInFromLeft, delay: 0.4)
            ivIsland.animateIn(mode: .animateInFromRight, delay: 0.5)
            ivShore1Shore.animateIn(mode: .animateInFromLeft, delay: 0.5)
            navigationView.animateIn(mode: .animateInFromTop, delay: 0.8)
            introAnimationDone = true
        }
        
    }
    
    /// Customize view
    override func customizeView() {
        
        //add geture recognizer for swipping horizontally
        let panRec1 = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        panRec1.delegate = self
        self.view.addGestureRecognizer(panRec1)
        
        self.ivShore2Girl.loadGif(name: "girl")
        
        self.ivShore3Girl1.loadGif(name: "girl_3_1")
        self.ivShore3Girl2.loadGif(name: "girl_3_2")
        
        //ivShore2Girl.loadGif(asset: "girl")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let bottle = sender as? Bottle {

            let nav = segue.destination as! UINavigationController
            let findBottleVC = nav.topViewController as! FindBottleViewController
            findBottleVC.shoreName = self.navigationView.navTitle.text
            findBottleVC.bottle = bottle
         }
    }
    
    @IBAction func throwBottlePressed(_ sender: UIButton) {
        self.wiggleAnimate(view: self.ivThrowBtn)
        self.performSegue(withIdentifier: "homeRecrodSegue", sender: self)
    }
    
    @IBAction func findBottlePressed(_ sender: UIButton) {
        
        self.ivFindBottle.loadGif(name: "find_bottle")
        self.wiggleAnimate(view: self.ivFindBtn)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { // delay 5 second
            self.ivFindBottle.image = nil
            self.showActivityLoader(true)
            ApiManager.shared.findBottle { (bottle, error) in
    
                if error == nil {
                    self.showActivityLoader(false)
                    //print("\(bottle?.bottle_id)")
                    self.performSegue(withIdentifier: "findBottleSegue", sender: bottle)
                    self.ivFindBottle.image = nil
                } else {
                    //print(erorr)
                }
            }
        }
    }
    
    @IBAction func myBottlesPressed(_ sender: UIButton) {
        self.wiggleAnimate(view: self.ivMyBottlesBtn)
        self.performSegue(withIdentifier: "myBottlesSegue", sender: self)
    }
    
    @IBAction func unwindRecordMedia(segue: UIStoryboardSegue) {
        
        self.ivThrowBottle.loadGif(name: "throwBottle")
        if let sourceController = segue.source as? PreviewMediaControl {
            switch sourceController.selectedShoreIndex {
            case 0:
                goToMainShore()
            case 1:
                goToLoveShore()
            case 2:
                goToFadFedShore()
            default:
                goToMainShore()
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // delay 6 second
                self.ivThrowBottle.image = nil
            }
        }
    }
    
    func wiggleAnimate(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        
        view.layer.add(animation, forKey: "position")
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
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: translation.x * self.loversParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: translation.x * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                } else if currentPageIndex == 1 {
                    //let transform = CGAffineTransform.identity.translatedBy(x: translation.x, y: 0)
                    let duration = 0.1
                    let trans = (self.screenWidth * -1) + translation.x
                    UIView.animate(withDuration: duration, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        // shore 2
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        // shore 3
                        self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore3ParallaxSpeed, y: 0)
                        self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: translation.x * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                }
            } else {
                // swipping back to previews view
                if currentPageIndex == 0 {
                    // no action to take
                } else if currentPageIndex == 1 {
                    let trans = (translation.x - self.screenWidth)
                    UIView.animate(withDuration: 0.1, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore1ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
                } else if currentPageIndex == 2 {
                    let trans = (translation.x - (self.screenWidth * 2))
                    UIView.animate(withDuration: 0.1, delay:0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                        self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: trans * self.seaParallaxSpeed, y: 0)
                        self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: trans * self.sunParallaxSpeed, y: 0)
                        self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: trans * self.cloudsParallaxSpeed, y: 0)
                        self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: trans * self.mountainsParallaxSpeed, y: 0)
                        self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: trans * self.island2ParallaxSpeed, y: 0)
                        self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore2ParallaxSpeed, y: 0)
                        self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: trans * self.loversParallaxSpeed, y: 0)
                        // shore 3
                        self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: trans * self.shore3ParallaxSpeed, y: 0)
                        self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: trans * self.friendsParallaxSpeed, y: 0)
                        
                        //self.discoverControl?.view.transform = CGAffineTransform.identity.translatedBy(x: (translation.x - self.screenWidth) * 0.4, y: 0)
                    }, completion: {(finished: Bool) in
                    })
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
                } else if ( currentPageIndex == 2 ) {
                    self.goToLoveShore()
                }
            } else if (translation.x <= -100) {
                // moving to next view
                if (currentPageIndex == 0) {
                    self.goToLoveShore()
                } else if currentPageIndex == 1 {
                    self.goToFadFedShore()
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
                } else {
                    self.goToFadFedShore()
                }
            }
        }
    }
    
    
    func goToMainShore() {
        
        if blockPageTransitions {
            return
        }
        blockPageTransitions = true
        //let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity
            self.ivIsland.transform = CGAffineTransform.identity
            self.ivShore1Shore.transform = CGAffineTransform.identity
            self.ivShore2Shore.transform = CGAffineTransform.identity
            self.ivShore3Shore.transform = CGAffineTransform.identity
            self.shore2Lovers.transform = CGAffineTransform.identity
            self.ivMountains.transform = CGAffineTransform.identity
            self.ivClouds.transform = CGAffineTransform.identity
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 0
            self.blockPageTransitions = false
            self.navigationView.navTitle.text = "main_shore".localized
        })
    }
    
    func goToLoveShore() {
        if blockPageTransitions {
            return
        }
        blockPageTransitions = true
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.seaParallaxSpeed), y: 0)
            self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.island2ParallaxSpeed), y: 0)
            self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore1ParallaxSpeed), y: 0)
            self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore2ParallaxSpeed), y: 0)
            self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.shore3ParallaxSpeed), y: 0)
            self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.friendsParallaxSpeed), y: 0)
            self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.loversParallaxSpeed), y: 0)
            self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.sunParallaxSpeed), y: 0)
            self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.cloudsParallaxSpeed), y: 0)
            self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: -(self.screenWidth * self.mountainsParallaxSpeed), y: 0)
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 1
            self.blockPageTransitions = false
            self.navigationView.navTitle.text = "love_shore".localized
        })
    }
    
    func goToFadFedShore() {
        if blockPageTransitions {
            return
        }
        blockPageTransitions = true
        //let transform = CGAffineTransform.identity.translatedBy(x: -screenWidth, y: 0)
        let doubleScreenWidth = self.screenWidth * 2
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping:0.70, initialSpringVelocity:2.2, options: .curveEaseInOut, animations: {
            self.ivSea.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.seaParallaxSpeed), y: 0)
            self.ivIsland.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.island2ParallaxSpeed), y: 0)
            self.ivShore1Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore1ParallaxSpeed), y: 0)
            self.ivShore2Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore2ParallaxSpeed), y: 0)
            self.ivShore3Shore.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.shore3ParallaxSpeed), y: 0)
            self.shore3Friends.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.friendsParallaxSpeed), y: 0)
            self.shore2Lovers.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.loversParallaxSpeed), y: 0)
            self.ivSun.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.sunParallaxSpeed), y: 0)
            self.ivClouds.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.cloudsParallaxSpeed), y: 0)
            self.ivMountains.transform = CGAffineTransform.identity.translatedBy(x: -(doubleScreenWidth * self.mountainsParallaxSpeed), y: 0)
        }, completion: {(finished: Bool) in
            self.currentPageIndex = 2
            self.blockPageTransitions = false
            self.navigationView.navTitle.text = "fadfed_shore".localized
        })
    }
    
    func showFilter () {
        if self.filterViewVisible {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.filterView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -self.filterView.frame.height - 50)
                self.filterViewOverlay.alpha = 0.0
            }, completion: {(finished: Bool) in
                self.filterViewVisible = false
                self.filterViewOverlay.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                self.filterView.transform = CGAffineTransform.identity
                self.filterViewOverlay.alpha = 1.0
            }, completion: {(finished: Bool) in
                self.filterViewVisible = true
                self.filterViewOverlay.isHidden = false
            })
        }
    }
    
    func showShopView() {
        self.performSegue(withIdentifier:"shopSegue", sender: self)
    }
    
}

extension HomeViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension HomeViewController: FilterViewDelegate {
    
    func getFilterInfo(gender: String, country: String) {
        print(gender)
        print(country)
        print("----------")
    }
}


