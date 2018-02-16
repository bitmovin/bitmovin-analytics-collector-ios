//
//  PlayerState.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

public enum PlayerState: String {
    case setup
    case buffering
    case error
    case playing
    case paused
    case qualitychange
    case seeking

    func onEntry(stateMachine: StateMachine, timestamp _: Int, destinationState _: PlayerState) {
        guard let delegate = stateMachine.delegate else {
            return
        }
        switch self {
        case .setup:
            return;
        case .buffering:
            return;
        case .error:
            delegate.stateMachineDidEnterError(stateMachine)
            return;
        case .playing, .paused:
            if stateMachine.firstReadyTimestamp == 0 {
                stateMachine.firstReadyTimestamp = Date().timeIntervalSince1970Millis
                delegate.stateMachine(stateMachine, didStartupWithDuration: stateMachine.startupTime)
            }
            stateMachine.enableHeartbeat()
            return;
        case .qualitychange:
            delegate.stateMachineDidQualityChange(stateMachine)
            return;
        case .seeking:
            return
        }
    }

    func onExit(stateMachine: StateMachine, timestamp: Int, destinationState: PlayerState) {
        guard let delegate = stateMachine.delegate else {
            return
        }

        // Get the duration we were in the state we are exiting
        let enterTimestamp = stateMachine.enterTimestamp ?? 0
        let duration = timestamp - enterTimestamp

        switch self {
        case .setup:
            delegate.stateMachineDidExitSetup(stateMachine)
            return;
        case .buffering:
            delegate.stateMachine(stateMachine, didExitBufferingWithDuration: duration)
            return;
        case .error:
            return;
        case .playing:
            delegate.stateMachine(stateMachine, didExitPlayingWithDuration: duration)
            stateMachine.disableHeartbeat()
            return;
        case .paused:
            delegate.stateMachine(stateMachine, didExitPauseWithDuration: duration)
            stateMachine.disableHeartbeat()
            return;
        case .qualitychange:
            delegate.stateMachineDidQualityChange(stateMachine)
            return;
        case .seeking:
            delegate.stateMachine(stateMachine, didExitSeekingWithDuration: duration, destinationPlayerState: destinationState)
            return
        }
    }
}
