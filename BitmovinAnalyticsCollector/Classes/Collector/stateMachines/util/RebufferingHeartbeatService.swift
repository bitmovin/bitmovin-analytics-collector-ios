//
//  RebufferingTimeService.swift
//  Pods
//
//  Created by Thomas Sablattnig on 21.09.22.
//

import Foundation

public class RebufferingHeartbeatService {
    private let queue = DispatchQueue(label:"com.bitmovin.analytics.core.utils.RebufferingHeartbeatService")
    private var rebufferHeartbeatTimer: DispatchWorkItem?
    private var currentRebufferIntervalIndex: Int = 0
    private let rebufferHeartbeatInterval: [Int64] = [3000, 5000, 10000, 59700]
    
    private weak var stateMachine: StateMachine?
    
    func initialise(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
    }
    
    func scheduleRebufferHeartbeat() {
        self.rebufferHeartbeatTimer = DispatchWorkItem { [weak self] in
            guard let self = self,
                self.rebufferHeartbeatTimer != nil else {
                return
            }
            self.stateMachine?.onHeartbeat()
            self.currentRebufferIntervalIndex = min(self.currentRebufferIntervalIndex + 1, self.rebufferHeartbeatInterval.count - 1)
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
    }
    
    private func getRebufferDeadline() -> DispatchTime {
        let interval = Double(rebufferHeartbeatInterval[currentRebufferIntervalIndex]) / 1_000.0
        return DispatchTime.now() + interval
    }
}
