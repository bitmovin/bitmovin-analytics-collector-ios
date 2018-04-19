//
//  BitmovinAnalytics.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import AVFoundation
import Foundation
import BitmovinPlayer

/**
 * An iOS analytics plugin that sends video playback analytics to Bitmovin Analytics servers. Currently
 * supports analytics on AVPlayer video players
 */
public class BitmovinAnalytics {
    static let msInSec = 1000.0
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
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    public func attachBitmovinPlayer(player: BitmovinPlayer) {
        stateMachine.delegate = self
        eventDataDispatcher.enable()
        adapter = BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
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
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeStart) * BitmovinAnalytics.msInSec)
        }
        if let timeEnd = stateMachine.videoTimeEnd {
            eventData.videoTimeEnd = Int(CMTimeGetSeconds(timeEnd) * BitmovinAnalytics.msInSec)
        }
        return eventData
    }
}

extension BitmovinAnalytics: StateMachineDelegate {

    func stateMachineDidExitSetup(_ stateMachine: StateMachine) {
    }

    func stateMachine(_ stateMachine: StateMachine, didExitBufferingWithDuration duration: Int) {
        let eventData = createEventData(duration: duration)
        sendEventData(eventData: eventData)
    }

    func stateMachineDidEnterError(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPlayingWithDuration duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.played = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitPauseWithDuration duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.paused = duration
        sendEventData(eventData: eventData)
    }

    func stateMachineDidQualityChange(_ stateMachine: StateMachine) {
        let eventData = createEventData(duration: 0)
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didExitSeekingWithDuration duration: Int, destinationPlayerState: PlayerState) {
        let eventData = createEventData(duration: duration)
        eventData?.seeked = duration
        sendEventData(eventData: eventData)
    }

    func stateMachine(_ stateMachine: StateMachine, didHeartbeatWithDuration duration: Int) {
        print("Heartbeat Fired")
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

    func stateMachine(_ stateMachine: StateMachine, didStartupWithDuration duration: Int) {
        let eventData = createEventData(duration: duration)
        eventData?.videoStartupTime = duration
        // Hard coding 1 as the player startup time to workaround a Dashboard issue
        eventData?.playerStartupTime = 1
        eventData?.startupTime = duration+1
        
        eventData?.state = "startup"
        sendEventData(eventData: eventData)
    }
}
