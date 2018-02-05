//
//  PlayerState.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

public enum PlayerStateEnum: String {
    case setup
    case buffering
    case error
    case playing
    case paused
    case qualitychange
    case seeking

    func onEntry(stateMachine: StateMachine, timestamp _: Int, destinationState _: PlayerStateEnum) {
        guard let delegate = stateMachine.delegate else {
            return
        }
        switch self {
        case .setup:
            return;
        case .buffering:
            return;
        case .error:
            delegate.didEnterError()
            return;
        case .playing, .paused:
            if stateMachine.firstReadyTimestamp == 0 {
                stateMachine.firstReadyTimestamp = Date().timeIntervalSince1970Millis
                delegate.didStartup(duration: stateMachine.startupTime)
            }
            stateMachine.enableHeartbeat()
            return;
        case .qualitychange:
            delegate.didQualityChange()
            return;
        case .seeking:
            return
        }
    }

    func onExit(stateMachine: StateMachine, timestamp: Int, destinationState: PlayerStateEnum) {
        guard let delegate = stateMachine.delegate else {
            return
        }

        // Get the duration we were in the state we are exiting
        let enterTimestamp = stateMachine.enterTimestamp ?? 0
        let duration = timestamp - enterTimestamp

        switch self {
        case .setup:
            delegate.didExitSetup()
            return;
        case .buffering:
            delegate.didExitBuffering(duration: duration)
            return;
        case .error:
            return;
        case .playing:
            delegate.didExitPlaying(duration: duration)
            stateMachine.disableHeartbeat()
            return;
        case .paused:
            delegate.didExitPause(duration: duration)
            stateMachine.disableHeartbeat()
            return;
        case .qualitychange:
            delegate.didQualityChange()
            return;
        case .seeking:
            delegate.didExitSeeking(duration: duration, destinationPlayerState: destinationState)
            return
        }
    }
}
