//  AVPlayerAdapter.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import AVFoundation
import Foundation

class AVPlayerAdapter: NSObject, PlayerAdapter {
    private static var playerKVOContext = 0
    private let stateMachine: StateMachine
    private let config: BitmovinAnalyticsConfig
    private var lastBitrate: Double = 0
    @objc private var player: AVPlayer?
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?

    init(player: AVPlayer, config: BitmovinAnalyticsConfig, stateMachine: StateMachine) {
        self.player = player
        self.stateMachine = stateMachine
        self.config = config
        lastBitrate = 0
    }

    deinit {
        stopMonitoringPlayerItem()
        stopMonitoring()
    }

    public func startMonitoring() {
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.currentItem), options: [.new, .initial], context: &AVPlayerAdapter.playerKVOContext)
    }

    public func stopMonitoring() {
        removeObserver(self, forKeyPath: #keyPath(player.rate), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &AVPlayerAdapter.playerKVOContext)
        removeObserver(self, forKeyPath: #keyPath(player.currentItem), context: &AVPlayerAdapter.playerKVOContext)
    }

    private func startMonitoringPlayerItem() {
        NotificationCenter.default.addObserver(self, selector: #selector(accessItemAdded(notification:)), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(timeJumped(notification:)), name: NSNotification.Name.AVPlayerItemTimeJumped, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(addedErrorLog(notification:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player?.currentItem)
    }

    private func stopMonitoringPlayerItem() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: player?.currentItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: player?.currentItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player?.currentItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player?.currentItem)
    }

    @objc private func addedErrorLog(notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else {
            return
        }
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog(), let errorLogEvent: AVPlayerItemErrorLogEvent = errorLog.events.last else {
            return
        }

        print(errorLogEvent.errorStatusCode)
    }

    @objc private func playbackStalled(notification _: Notification) {
        stateMachine.transitionState(destinationState: .buffering, time: player?.currentTime())
    }

    @objc private func timeJumped(notification _: Notification) {
        let timestamp = Date().timeIntervalSince1970Millis
        if (timestamp - stateMachine.potentialSeekStart) > 1000 {
            print("Time Jumped")
            stateMachine.potentialSeekStart = timestamp
            stateMachine.potentialSeekVideoTimeStart = player?.currentTime()
        }
    }

    @objc private func accessItemAdded(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, let event = item.accessLog()?.events.last else {
            return
        }
        if lastBitrate == 0 {
            lastBitrate = event.indicatedBitrate
        } else if lastBitrate != event.indicatedBitrate {
            let previousState = stateMachine.state
            stateMachine.transitionState(destinationState: .qualitychange, time: player?.currentTime())
            stateMachine.transitionState(destinationState: previousState, time: player?.currentTime())
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
            if newRate == 0.0 && stateMachine.firstReadyTimestamp > 0 {
                stateMachine.transitionState(destinationState: .paused, time: self.player?.currentTime())
            } else if newRate > 0.0 && stateMachine.firstReadyTimestamp > 0 {
                stateMachine.transitionState(destinationState: .playing, time: self.player?.currentTime())
            }
        } else if keyPath == #keyPath(player.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                let timestamp = Date().timeIntervalSince1970Millis
                switch newStatus {
                case .readyToPlay:
                    if stateMachine.firstReadyTimestamp > 0 && (timestamp - stateMachine.potentialSeekStart) <= 10000 {
                        print("Seek Confirmed")
                        stateMachine.transitionState(destinationState: .seeking, time: self.player?.currentTime())
                        stateMachine.confirmSeek()
                    }

                    if player?.rate == 0 {
                        stateMachine.transitionState(destinationState: .paused, time: self.player?.currentTime())
                    } else if player?.rate > 0 {
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
        } else if keyPath == #keyPath(player.currentItem) {
            if let currentItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                NSLog("Current Item Changed: %@", currentItem.debugDescription)
                startMonitoringPlayerItem()
            }
        }
    }

    public func createEventData() -> EventData {
        let eventData: EventData = EventData(config: config, impressionId: stateMachine.impressionId)
        decorateEventData(eventData: eventData)
        return eventData
    }

    private func decorateEventData(eventData: EventData) {
        // Player
        eventData.player = PlayerType.avplayer.rawValue

        // Player Tech
        eventData.playerTech = "ios:avplayer"

        // Error Code
        if player?.currentItem?.status == .failed {
            if let errorLog = player?.currentItem?.errorLog(), let errorLogEvent: AVPlayerItemErrorLogEvent = errorLog.events.first {
                eventData.errorCode = errorLogEvent.errorStatusCode
                eventData.errorMessage = errorLogEvent.errorComment
            }
        }

        // Error Message
        eventData.errorMessage = player?.error?.localizedDescription

        // Duration
        if let duration = player?.currentItem?.duration, CMTIME_IS_NUMERIC(_: duration) {
            eventData.videoDuration = Int(CMTimeGetSeconds(duration) * 1000)
        }

        // isCasting
        eventData.isCasting = player?.isExternalPlaybackActive

        // isLive
        if let duration = player?.currentItem?.duration {
            eventData.isLive = CMTIME_IS_INDEFINITE(duration)
        }

        // version
        eventData.version = UIDevice.current.systemVersion

        // streamFormat, hlsUrl
        eventData.streamForamt = "hls"
        if let urlAsset = player?.currentItem?.asset as? AVURLAsset {
            eventData.m3u8Url = urlAsset.url.absoluteString
        }

        // audio bitrate
        if let asset = player?.currentItem?.asset {
            if asset.tracks.count > 0 {
                let tracks = asset.tracks(withMediaType: .audio)
                if tracks.count > 0 {
                    let desc = tracks[0].formatDescriptions[0] as! CMAudioFormatDescription
                    let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
                    if let sampleRate = basic?.pointee.mSampleRate {
                        eventData.audioBitrate = sampleRate
                    }
                }
            }
        }

        // video bitrate
        eventData.videoBitrate = lastBitrate

        // videoPlaybackWidth
        if let width = player?.currentItem?.presentationSize.width {
            eventData.videoPlaybackWidth = Int(width)
        }

        // videoPlaybackHeight
        if let height = player?.currentItem?.presentationSize.height {
            eventData.videoPlaybackHeight = Int(height)
        }

        let scale = UIScreen.main.scale
        // screenHeight
        eventData.screenHeight = Int(UIScreen.main.bounds.size.height * scale)

        // screenWidth
        eventData.screenWidth = Int(UIScreen.main.bounds.size.width * scale)

        // isMuted
        if player?.volume == 0 {
            eventData.isMuted = true
        }
    }
}
