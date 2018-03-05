//
//  PickerViewController.swift
//  Vobble
//
//  Created by Bayan on 3/4/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation

class PickerViewController: AbstractController {
        
        
    @IBOutlet var vp: VideoPlayerView!
    
    let videoPickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    @IBAction func browseVideoBtn(_ sender: Any) {
        
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.delegate = self
        videoPickerController.mediaTypes = ["public.movie"]
        
        present(videoPickerController, animated: true, completion: nil)

    }
    
}

extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
        videoPickerController.dismiss(animated: true, completion: nil)
        if let url = videoURL?.absoluteString {
            vp.preparePlayer(videoURL: url)
        }
        
    }
}
