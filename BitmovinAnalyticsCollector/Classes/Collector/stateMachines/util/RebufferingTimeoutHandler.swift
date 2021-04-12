import Foundation

public class RebufferingTimeoutHandler {
    private static var kAnalyticsRebufferingTimeoutIntervalId = "com.bitmovin.analytics.core.utils.RebufferingTimeoutHandler"
    private static var kAnalyticsRebufferingTimeoutSeconds: TimeInterval = 2 * 60
    
    private var rebufferingTimeoutWorkItem: DispatchWorkItem?
    private weak var stateMachine: StateMachine?
    
    func initialise(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
    }
    
    func startInterval() {
        resetInterval()
        rebufferingTimeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.stateMachine?.rebufferTimeoutReached(time: self.stateMachine?.delegate?.currentTime)
            self.resetInterval()
        }

        DispatchQueue.init(label: RebufferingTimeoutHandler.kAnalyticsRebufferingTimeoutIntervalId).asyncAfter(deadline: .now() + RebufferingTimeoutHandler.kAnalyticsRebufferingTimeoutSeconds, execute: rebufferingTimeoutWorkItem!)
    }

    func resetInterval() {
        if (rebufferingTimeoutWorkItem == nil) {
            return
        }

        rebufferingTimeoutWorkItem?.cancel()
        rebufferingTimeoutWorkItem = nil
    }
}
