//
//  StateMachine.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation
import AVFoundation

public class StateMachine {
    private(set) var state: PlayerStateEnum
    private var config: BitmovinAnalyticsConfig
    private var initialTimestamp: Int;
    private(set) var enterTimestamp: Int?;
    var firstReadyTimestamp: Int = 0;
    var seekTimestamp: Int?;
    private(set) var videoTimeStart: CMTime?
    private(set) var videoTimeEnd: CMTime?
    private(set) var impressionId: String
    weak var delegate: StateMachineDelegate?
    private var heartbeatTimer: Timer?
    
    var startupTime: Int {
        get {
            return firstReadyTimestamp - initialTimestamp
        }
    }
    
    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        self.state = .setup
        self.initialTimestamp = Date().timeIntervalSince1970Millis
        self.impressionId = NSUUID().uuidString
    }
    
    private func resetStateMachine() {
        self.impressionId = NSUUID().uuidString
        self.initialTimestamp = Date().timeIntervalSince1970Millis
    }
    
    public func transitionState(destinationState: PlayerStateEnum, time: CMTime?){
        if(state == destinationState) {
            return
        }else{
            print("Transitioning from \(state.rawValue) to \(destinationState.rawValue)")
            let timestamp = Date().timeIntervalSince1970Millis
            videoTimeEnd = time
            self.state.onExit(stateMachine: self, timestamp: timestamp, destinationState: destinationState)
            self.state = destinationState;
            self.enterTimestamp = timestamp
            self.videoTimeStart = videoTimeEnd
            self.state.onEntry(stateMachine: self,timestamp: timestamp,destinationState: destinationState)
        }
    }
    
    func enableHeartbeat(){
        let interval = Double(config.heartbeatInterval) / 1000.0
        heartbeatTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(StateMachine.onHeartbeat), userInfo: nil, repeats: true)
    }
    
    func disableHeartbeat(){
        heartbeatTimer?.invalidate()
    }
    
    
    @objc func onHeartbeat()
    {
        let timestamp = Date().timeIntervalSince1970Millis
        guard let enterTime = enterTimestamp else {
            return
        }
        delegate?.heartbeatFired(duration: enterTime - timestamp)
        enterTimestamp = timestamp
    }
}
