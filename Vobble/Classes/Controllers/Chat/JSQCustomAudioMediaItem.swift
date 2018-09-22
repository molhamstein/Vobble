//
//  JSQCustomVideoItem.swift
//  Vobble
//
//  Created by Bayan on 4/1/18.
//  Copyright © 2018 Brain-Socket. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JSQCustomAudioMediaItem: JSQAudioMediaItem {
    
    var audioUrl: URL?
    var LoadingAudioSpinner: UIActivityIndicatorView?
    
//    override var audioData: Data? {
//        set {
//            print("set audio")
//        }
//        get {
//            return _audioData
//        }
//    }
        
    func onPlayButton(sender: UIButton) {
        if let data = self.audioData, data.count > 0 {
            super.onPlay(sender)
        } else {
            // download the data first
            if let url = audioUrl, url.isValidUrl() {
                self.LoadingAudioSpinner?.isHidden = false
                self.LoadingAudioSpinner?.startAnimating()
                self.playButton.isHidden = true
                downloadAudioData(url: url)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadAudioData(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.audioData = data
                do {
                    try self.audioPlayer = AVAudioPlayer.init(data: data)
                    self.audioPlayer.delegate = self;
                } catch {}
                self.LoadingAudioSpinner?.isHidden = true
                self.playButton.isHidden = false
                self.onPlay(self.playButton)
            }
        }
    }
    
    override func mediaView() -> UIView! {
        let view = super.mediaView()
        self.playButton.removeTarget(nil, action: nil, for: .allEvents)
        self.playButton.addTarget(self, action: #selector(self.onPlayButton(sender:)), for: .touchUpInside)
        self.progressLabel.text = "--:--"
        
        self.LoadingAudioSpinner = UIActivityIndicatorView()
        self.LoadingAudioSpinner?.frame = self.playButton.frame
        self.LoadingAudioSpinner?.activityIndicatorViewStyle = .white
        view?.addSubview(self.LoadingAudioSpinner!)
        
        // if url is not set set this mean the pee is still uploading the message and we should show a spinner
        if let url = audioUrl, url.isValidUrl() {
            self.LoadingAudioSpinner?.isHidden = true
        } else {
            self.LoadingAudioSpinner?.isHidden = false
        }
        
        return view
    }
    
}
