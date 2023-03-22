import Foundation

class RebufferingHeartbeatService {
    private static let heartbeatIntervals: [Int64] = [3_000, 5_000, 10_000, 59_700]

    private let queue = DispatchQueue(label: "com.bitmovin.analytics.core.utils.RebufferingHeartbeatService")
    private var heartbeatWorkerItem: DispatchWorkItem?
    private var currentIntervalIndex: Int = 0
    private let timeoutHandler: RebufferingTimeoutHandler

    weak var listener: RebufferHeartbeatListener?

    init(timeoutHandler: RebufferingTimeoutHandler) {
        self.timeoutHandler = timeoutHandler
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
            self.listener?.onRebufferHeartbeat()
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
