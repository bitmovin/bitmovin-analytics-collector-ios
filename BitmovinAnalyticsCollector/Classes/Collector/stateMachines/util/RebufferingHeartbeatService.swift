//
//  RebufferingTimeService.swift
//  Pods
//
//  Created by Thomas Sablattnig on 21.09.22.
//

import Foundation

public class RebufferingHeartbeatService {
    private static let rebufferHeartbeatInterval: [Int64] = [3000, 5000, 10000, 59700]
    
    private let queue = DispatchQueue(label:"com.bitmovin.analytics.core.utils.RebufferingHeartbeatService")
    private var rebufferHeartbeatTimer: DispatchWorkItem?
    private var currentRebufferIntervalIndex: Int = 0
    
    private weak var stateMachine: StateMachine?
    
    private let timeoutHandler: RebufferingTimeoutHandler = RebufferingTimeoutHandler()

    func initialise(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
        self.timeoutHandler.initialise(stateMachine: stateMachine)
    }
    
    func startRebufferHeartbeat() {
        scheduleRebufferHeartbeat()
        timeoutHandler.startInterval()
    }
    
    private func scheduleRebufferHeartbeat() {
        self.rebufferHeartbeatTimer = DispatchWorkItem { [weak self] in
            guard let self = self,
                self.rebufferHeartbeatTimer != nil else {
                return
            }
            self.stateMachine?.onHeartbeat()
            self.currentRebufferIntervalIndex = min(self.currentRebufferIntervalIndex + 1, RebufferingHeartbeatService.rebufferHeartbeatInterval.count - 1)
            self.scheduleRebufferHeartbeat()
        }
        self.queue.asyncAfter(deadline: getRebufferDeadline(), execute: self.rebufferHeartbeatTimer!)
    }

    func disableRebufferHeartbeat() {
        self.queue.sync {
            self.rebufferHeartbeatTimer?.cancel()
            self.rebufferHeartbeatTimer = nil
            self.currentRebufferIntervalIndex = 0
        }
        timeoutHandler.resetInterval()
    }
    
    private func getRebufferDeadline() -> DispatchTime {
        let interval = Double(RebufferingHeartbeatService.rebufferHeartbeatInterval[currentRebufferIntervalIndex]) / 1_000.0
        return DispatchTime.now() + interval
    }
}
