import Foundation

public class RebufferingTimeoutHandler {
    private static var rebufferingTimeoutSeconds: TimeInterval = 2 * 60

    private let queue = DispatchQueue(label: "com.bitmovin.analytics.core.utils.RebufferingTimeoutHandler")
    private var rebufferingTimeoutWorkItem: DispatchWorkItem?
    private weak var stateMachine: StateMachine?

    func initialise(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
    }

    func startInterval() {
        resetInterval()
        rebufferingTimeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.rebufferTimeoutReached()
            self.resetInterval()
        }

        queue.asyncAfter(deadline: .now() + RebufferingTimeoutHandler.rebufferingTimeoutSeconds, execute: rebufferingTimeoutWorkItem!)
    }

    private func rebufferTimeoutReached() {
        stateMachine?.error(withError: ErrorData.BUFFERING_TIMEOUT_REACHED, time: stateMachine?.delegate?.currentTime)
        stateMachine?.delegate?.stateMachineStopsCollecting()
    }

    func resetInterval() {
        if rebufferingTimeoutWorkItem == nil {
            return
        }

        rebufferingTimeoutWorkItem?.cancel()
        rebufferingTimeoutWorkItem = nil
    }
}
