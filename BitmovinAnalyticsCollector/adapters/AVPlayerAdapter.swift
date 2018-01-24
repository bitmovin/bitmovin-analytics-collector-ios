//  AVPlayerAdapter.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation
import AVFoundation

class AVPlayerAdapter:NSObject,PlayerAdapter {
    
    private static var playerKVOContext = 0
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var lastBitrate: Double = 0
    @objc private var player: AVPlayer?
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    
    init(player: AVPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine){
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        self.lastBitrate = 0
    }
    
    public func startMonitoring(){
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options: [.new, .initial], context:&AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem), options: [.new, .initial], context:&AVPlayerAdapter.playerKVOContext)
    }
    
    private func startMonitoringPlayerItem(){
        NotificationCenter.default.addObserver(self, selector: #selector(accessItemAdded(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(timeJumped(notification:)), name: NSNotification.Name.AVPlayerItemTimeJumped, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(addedErrorLog(notification:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: self.player?.currentItem)
    }


    @objc private func addedErrorLog(notification: Notification){
        print("Error Log Added")
    }
    
    @objc private func playbackStalled(notification: Notification){
        stateMachine.transitionState(destinationState: .buffering, time: player?.currentTime())
    }
    
    @objc private func didPlayToEndTime(notification: Notification){
        print("Did Play to End Time")
    }
    
    @objc private func failedToPlayToEndTime(notification: Notification){
        print("Did Play to End Time")
    }
    
    @objc private func timeJumped(notification: Notification){
        stateMachine.potentialSeekStart = Date().timeIntervalSince1970Millis
        stateMachine.potentialSeekVideoTimeStart = player?.currentTime()
    }
    
    @objc private func accessItemAdded(notification: Notification){
        guard let item = notification.object as? AVPlayerItem, let event = item.accessLog()?.events.last else {
            return
        }
        if(lastBitrate == 0){
            lastBitrate = event.indicatedBitrate;
        }else if (lastBitrate != event.indicatedBitrate){
            let previousState = stateMachine.state
            stateMachine.transitionState(destinationState: .qualitychange, time: self.player?.currentTime())
            stateMachine.transitionState(destinationState: previousState, time: self.player?.currentTime())
            lastBitrate = event.indicatedBitrate
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &AVPlayerAdapter.playerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            if (newRate == 0.0 && stateMachine.firstReadyTimestamp > 0){
                stateMachine.transitionState(destinationState: .paused, time: self.player?.currentTime())
            }else if (newRate == 1.0  && stateMachine.firstReadyTimestamp > 0){
                stateMachine.transitionState(destinationState: .playing, time: self.player?.currentTime())
            }
        }else if keyPath == #keyPath(player.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                let timestamp = Date().timeIntervalSince1970Millis
                switch newStatus {
                case .readyToPlay:
                    
                    if(stateMachine.firstReadyTimestamp > 0 && (timestamp - stateMachine.potentialSeekStart) <= 10000 ){
                        stateMachine.confirmSeek()
                        stateMachine.transitionState(destinationState: .seeking, time: self.player?.currentTime())
                    }
                    
                    if (player?.rate == 0){
                        stateMachine.transitionState(destinationState: .paused, time: self.player?.currentTime())
                    }else if(player?.rate == 1){
                        stateMachine.transitionState(destinationState: .playing, time: self.player?.currentTime())
                    }
                    break
                case .failed:
                    stateMachine.transitionState(destinationState: .error, time: self.player?.currentTime())
                    break
                default:
                    break
                
                }
            }
        }else if keyPath == #keyPath(player.currentItem){ 
            if let currentItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@",currentItem.debugDescription)
                startMonitoringPlayerItem()
            }
        }
    }
    
    public func createEventData() -> EventData {
        let eventData: EventData = EventData(config:config,impressionId:stateMachine.impressionId);
        eventData.player = PlayerType.avplayer.rawValue
        decorateEventData(eventData: eventData)
        return eventData
    }

    private func decorateEventData(eventData: EventData){
        
        //Duration
        if let duration = player?.currentItem?.duration, CMTIME_IS_NUMERIC(_: duration) {
            eventData.videoDuration = Int(CMTimeGetSeconds(duration)*1000)
        }
        
        //isCasting
        eventData.isCasting = player?.isExternalPlaybackActive
        
        //isLive
        if let duration = player?.currentItem?.duration {
            eventData.isLive = CMTIME_IS_INDEFINITE(duration)
        }
        
        //version
        eventData.version = UIDevice.current.systemVersion
        
        //streamFormat, hlsUrl
        eventData.streamForamt = "hls"
        if let urlAsset = player?.currentItem?.asset as? AVURLAsset {
            eventData.m3u8Url = urlAsset.url.absoluteString
        }
        
        //audio bitrate
        
        //video bitrate
        eventData.videoBitrate = lastBitrate
        
        //width
        if let urlAsset = player?.currentItem?.asset as? AVURLAsset {
            let tracks = urlAsset.tracks(withMediaType: .video)
            for track:AVAssetTrack in tracks {
                print(track)
            }
            
        }

        
        //height
        
        
        
    }

}
