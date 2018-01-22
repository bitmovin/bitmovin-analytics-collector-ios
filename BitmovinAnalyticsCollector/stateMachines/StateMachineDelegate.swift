//
//  StateMachineDelegate.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/16/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

protocol StateMachineDelegate: class {
    func didExitSetup()
    func didExitBuffering(duration: Int)
    func didEnterError()
    func didExitPlaying(duration: Int)
    func didExitPause(duration: Int)
    func didQualityChange()
    func didExitSeeking(duration: Int, destinationPlayerState: PlayerStateEnum)
    func heartbeatFired(duration: Int)
    func didStartup(duration: Int)
}
