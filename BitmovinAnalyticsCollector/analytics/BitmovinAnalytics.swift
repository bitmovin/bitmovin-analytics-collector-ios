//
//  BitmovinAnalytics.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation
import AVFoundation

/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
 */
public class BitmovinAnalytics:StateMachineDelegate {
    private var config: BitmovinAnalyticsConfig
    private var adapter: PlayerAdapter?
    private var stateMachine: StateMachine
    private var eventDataDispatcher: EventDataDispatcher
    
    public init(config: BitmovinAnalyticsConfig) {
        self.config = config
        self.stateMachine = StateMachine(config: self.config)
        self.eventDataDispatcher = SimpleEventDataDispatcher(config: config)
    }
    
    public func detachPlayer(){
        self.eventDataDispatcher.disable()
        self.stateMachine.reset()
        self.adapter = nil
    }
    
    public func attachAVPlayer(player: AVPlayer) {
        self.stateMachine.delegate = self
        self.eventDataDispatcher.enable()
        self.adapter = AVPlayerAdapter(player: player, config: config, stateMachine: self.stateMachine)
        self.adapter?.startMonitoring()
    }
    
    func didExitSetup() {
    }
    
    func didExitBuffering(duration: Int) {
        let eventData = createEventData(duration: duration)
        sendEventData(eventData: eventData)
    }
    
    func didEnterError() {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }
    
    func didExitPlaying(duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.played = duration
        sendEventData(eventData: eventData)
    }
    
    func didExitPause(duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.paused = duration
        sendEventData(eventData: eventData)
    }
    
    func didQualityChange() {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }
    
    func didExitSeeking(duration: Int, destinationPlayerState: PlayerStateEnum) {
        let eventData = createEventData(duration: duration)
        eventData?.seeked = duration
        sendEventData(eventData: eventData)
    }
    
    func heartbeatFired(duration: Int) {
        let eventData = createEventData(duration: duration)
        switch stateMachine.state {
        case .playing:
            eventData?.played = duration
            break
        case .paused:
            eventData?.paused = duration
            break
        case .buffering:
            eventData?.buffered = duration
            break
        default:
            break
        }
        sendEventData(eventData: eventData)
    }
    
    func didStartup(duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.videoStartupTime = duration
        eventData?.startupTime = duration
        eventData?.state = "startup"
        sendEventData(eventData: eventData)
    }
    
    private func sendEventData(eventData: EventData?){
        guard let data = eventData else {
            return
        }
        eventDataDispatcher.add(eventData: data)
    }
    
    private func createEventData(duration: Int) -> EventData? {
        guard let eventData = adapter?.createEventData() else {
            return nil
        }
        eventData.state = stateMachine.state.rawValue
        eventData.duration = duration
        
        if let timeStart = stateMachine.videoTimeStart {
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeStart)*1000)
        }
        if let timeEnd = stateMachine.videoTimeEnd {
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeEnd)*1000)
        }
        return eventData
    }
}
