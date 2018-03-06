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
        switch self {
        case .setup:
            return
        case .buffering:
            return
        case .error:
            stateMachine.delegate?.stateMachineDidEnterError(stateMachine)
            return
        case .playing, .paused:
            if (stateMachine.firstReadyTimestamp == nil) {
                stateMachine.firstReadyTimestamp = Date().timeIntervalSince1970Millis
                stateMachine.delegate?.stateMachine(stateMachine, didStartupWithDuration: stateMachine.startupTime)
            }
            stateMachine.enableHeartbeat()
            return
        case .qualitychange:
            stateMachine.delegate?.stateMachineDidQualityChange(stateMachine)
            return
        case .seeking:
            return
        }
    }

    func onExit(stateMachine: StateMachine, timestamp: Int, destinationState: PlayerState) {
        // Get the duration we were in the state we are exiting
        let enterTimestamp = stateMachine.enterTimestamp ?? 0
        let duration = timestamp - enterTimestamp

        switch self {
        case .setup:
            stateMachine.delegate?.stateMachineDidExitSetup(stateMachine)
            return
        case .buffering:
            stateMachine.delegate?.stateMachine(stateMachine, didExitBufferingWithDuration: duration)
            return
        case .error:
            return
        case .playing:
            stateMachine.delegate?.stateMachine(stateMachine, didExitPlayingWithDuration: duration)
            stateMachine.disableHeartbeat()
            return
        case .paused:
            stateMachine.delegate?.stateMachine(stateMachine, didExitPauseWithDuration: duration)
            stateMachine.disableHeartbeat()
            return
        case .qualitychange:
            stateMachine.delegate?.stateMachineDidQualityChange(stateMachine)
            return
        case .seeking:
            stateMachine.delegate?.stateMachine(stateMachine, didExitSeekingWithDuration: duration, destinationPlayerState: destinationState)
            return
        }
    }
}
