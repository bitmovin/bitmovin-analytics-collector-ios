//
import Foundation

public class RebufferingHeartbeatService {
    private static let heartbeatIntervals: [Int64] = [3_000, 5_000, 10_000, 59_700]

    private let queue = DispatchQueue(label: "com.bitmovin.analytics.core.utils.RebufferingHeartbeatService")
    private var heartbeatWorkerItem: DispatchWorkItem?
    private var currentIntervalIndex: Int = 0

    private weak var stateMachine: DefaultStateMachine?

    private let timeoutHandler = RebufferingTimeoutHandler()

    func initialise(stateMachine: DefaultStateMachine) {
        self.stateMachine = stateMachine
        self.timeoutHandler.initialise(stateMachine: stateMachine)
    }

    func startHeartbeat() {
        scheduleHeartbeat()
        timeoutHandler.startInterval()
    }

    private func scheduleHeartbeat() {
        self.heartbeatWorkerItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                self.heartbeatWorkerItem != nil else {
                return
            }
            self.stateMachine?.onHeartbeat()
            self.currentIntervalIndex = min(self.currentIntervalIndex + 1, RebufferingHeartbeatService.heartbeatIntervals.count - 1)
            self.scheduleHeartbeat()
        }
        self.queue.asyncAfter(deadline: getNextDeadline(), execute: self.heartbeatWorkerItem!)
    }

    func disableHeartbeat() {
        self.queue.sync {
            self.heartbeatWorkerItem?.cancel()
            self.heartbeatWorkerItem = nil
            self.currentIntervalIndex = 0
        }
        timeoutHandler.resetInterval()
    }

    private func getNextDeadline() -> DispatchTime {
        let interval = Double(RebufferingHeartbeatService.heartbeatIntervals[currentIntervalIndex]) / 1_000.0
        return DispatchTime.now() + interval
    }
}
