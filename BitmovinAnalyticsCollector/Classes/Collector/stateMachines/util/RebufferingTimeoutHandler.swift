import Foundation

public class RebufferingTimeoutHandler {
    private static var kAnalyticsRebufferingTimeoutIntervalId = "com.bitmovin.analytics.core.utils.RebufferingTimeoutHandler"
    private static var kAnalyticsRebufferingTimeoutSeconds: TimeInterval = 2 * 60
    private static var kAnalyticsRebufferingTimeoutErrorCode = 10001
    private static var kAnalyticsRebufferingTimeoutErrorMessage = "ANALYTICS_BUFFERING_TIMEOUT_REACHED"
    
    private var rebufferingTimeoutWorkItem: DispatchWorkItem?
    private var stateMachine: StateMachine
    
    
    init(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
    }
    
    func startInterval() {
        resetInterval()
        rebufferingTimeoutWorkItem = DispatchWorkItem {
            self.stateMachine.delegate?.stateMachineDidEnterError(self.stateMachine,
                                                                  data:[BitmovinAnalyticsInternal.ErrorCodeKey: RebufferingTimeoutHandler.kAnalyticsRebufferingTimeoutErrorCode,
                                                                        BitmovinAnalyticsInternal.ErrorMessageKey: RebufferingTimeoutHandler.kAnalyticsRebufferingTimeoutErrorMessage] )
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
