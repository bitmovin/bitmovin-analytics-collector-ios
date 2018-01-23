//
//  ViewController.swift
//  BitmovinAnalyticsSampleApp
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import UIKit
import AVKit
import BitmovinAnalyticsCollector

class ViewController: UIViewController {
    
    private static var playerViewControllerKVOContext = 0
    private var analyticsCollector: BitmovinAnalytics
    @objc private let player: AVPlayer = AVPlayer()
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var endDuration: UILabel!
    @IBOutlet weak var position: UILabel!
    
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    
    
    @IBOutlet weak var playerView: PlayerView!
    private var timeObserverToken: Any?
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    var rate: Float {
        get {
            return player.rate
        }
        
        set {
            player.rate = newValue
        }
    }
    
    /*
     A formatter for individual date components used to provide an appropriate
     value for the `startTimeLabel` and `durationLabel`.
     */
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:"9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac",playerKey:"18ca6ad5-9768-4129-bdf6-17685e0d14d2")
        config.cdnProvider = .akamai
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiement-1"
        config.videoId = "iOSHLSStatic"
        config.path = "/vod/breadcrumb/"
        
        analyticsCollector = BitmovinAnalytics(config: config);
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerView.playerLayer.player = player
        createPlayer()
        addObserver(self, forKeyPath: #keyPath(ViewController.player.rate), options: [.new, .initial], context: &ViewController.playerViewControllerKVOContext)
        analyticsCollector.attachAVPlayer(player: player);
    }
    
    @IBAction func createPlayer(){
        /*
         Update the UI when these player properties change.
         
         Use the context parameter to distinguish KVO for our particular observers
         and not those destined for a subclass that also happens to be observing
         these properties.
         */
        
        
        addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.duration), options: [.new, .initial], context: &ViewController.playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.status), options: [.new, .initial], context: &ViewController.playerViewControllerKVOContext)
        
        let movieURL = URL(string: "http://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
        let  asset = AVURLAsset(url: movieURL!, options: nil)
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        player.play()
        // Make sure we don't have a strong reference cycle by only capturing self as weak.
        let interval = CMTimeMake(1, 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
            let position = Float(CMTimeGetSeconds(time))
            
            self.slider.value = Float(position)
            self.position.text = self.createTimeString(time: position)
        }
    }
    
    
    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &ViewController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(ViewController.player.currentItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
            
            slider.maximumValue = Float(newDurationSeconds)
            slider.value = currentTime
            
            rewindButton.isEnabled = hasValidDuration
            
            playButton.isEnabled = hasValidDuration
            
            fastForwardButton.isEnabled = hasValidDuration
            
            slider.isEnabled = hasValidDuration
            
            position.isEnabled = hasValidDuration
            position.text = createTimeString(time: currentTime)
            
            endDuration.isEnabled = hasValidDuration
            endDuration.text = createTimeString(time: Float(newDurationSeconds))
        }
        else if keyPath == #keyPath(ViewController.player.rate) {
            // Update `playPauseButton` image.
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            
            let buttonImageName = newRate == 1.0 ? "PauseButton" : "PlayButton"
            
            let buttonImage = UIImage(named: buttonImageName)
            
            playButton.setImage(buttonImage, for: UIControlState())
        }
        else if keyPath == #keyPath(ViewController.player.currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                //                handleErrorWithMessage(player.currentItem?.error?.localizedDescription, error:player.currentItem?.error)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        if player.rate != 1.0 {
            player.play()
        }
        else {
            // Playing, so pause.
            player.pause()
        }
    }
    
    @IBAction func jumpForwardButtomPressed(_ sender: UIButton) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, 30)
        print("Seek To Time \(CMTimeAdd(currentTime, deltaTime))")
        player.seek(to: CMTimeAdd(currentTime, deltaTime), completionHandler: { (completed) in
            if(completed){
                print("Seek Completed")
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, 30)
        print("Seek To Time \(CMTimeSubtract(currentTime, deltaTime))")
        player.seek(to: CMTimeSubtract(currentTime, deltaTime), completionHandler: { (completed) in
            if(completed){
                print("Seek Completed")
            }
        })
    }
    
    @IBAction func rewindButtonWasPressed(_ sender: UIButton) {
        // Rewind no faster than -2.0.
        rate = max(player.rate - 2.0, -2.0)
    }
    
    @IBAction func fastForwardButtonWasPressed(_ sender: UIButton) {
        // Fast forward no faster than 2.0.
        rate = min(player.rate + 2.0, 2.0)
    }
    
    @IBAction func timeSliderDidChange(_ sender: UISlider) {
        print("Slider Changed: \(slider.value)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Convenience
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
