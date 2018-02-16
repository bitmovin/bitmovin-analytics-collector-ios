//
//  BitmovinAnalytics.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import AVFoundation
import Foundation

/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
 */
public class BitmovinAnalytics {
    private var config: BitmovinAnalyticsConfig
    private var adapter: PlayerAdapter?
    private var stateMachine: StateMachine
    private var eventDataDispatcher: EventDataDispatcher

    public init(config: BitmovinAnalyticsConfig) {
        self.config = config
        stateMachine = StateMachine(config: self.config)
        eventDataDispatcher = SimpleEventDataDispatcher(config: config)
        NotificationCenter.default.addObserver(self, selector: #selector(licenseFailed(notification:)), name: .licenseFailed, object: eventDataDispatcher)
    }

    /**
     * Detach the current player that is being used with Bitmovin Analytics.
     */
    public func detachPlayer() {
        eventDataDispatcher.disable()
        stateMachine.reset()
        adapter = nil
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    public func attachAVPlayer(player: AVPlayer) {
        stateMachine.delegate = self
        eventDataDispatcher.enable()
        adapter = AVPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        adapter?.startMonitoring()
    }

    @objc private func licenseFailed(notification _: Notification) {
        detachPlayer()
    }

    private func sendEventData(eventData: EventData?) {
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
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeStart) * 1000)
        }
        if let timeEnd = stateMachine.videoTimeEnd {
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeEnd) * 1000)
        }
        return eventData
    }
}

extension BitmovinAnalytics: StateMachineDelegate {
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
    
    func didExitSeeking(duration: Int, destinationPlayerState _: PlayerState) {
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
}
