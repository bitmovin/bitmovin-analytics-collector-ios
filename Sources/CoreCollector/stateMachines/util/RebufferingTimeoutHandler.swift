import Foundation

// could be generified to TimeoutHandler
public class RebufferingTimeoutHandler {
    private static var rebufferingTimeoutSeconds: TimeInterval = 2 * 60

    private let queue = DispatchQueue(label: "com.bitmovin.analytics.core.utils.RebufferingTimeoutHandler")
    private var rebufferingTimeoutWorkItem: DispatchWorkItem?
    weak var listeners: RebufferTimeoutListener?

    func startInterval() {
        resetInterval()
        rebufferingTimeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.listeners?.onRebufferTimeout()
            self.resetInterval()
        }

        queue.asyncAfter(deadline: .now() + RebufferingTimeoutHandler.rebufferingTimeoutSeconds, execute: rebufferingTimeoutWorkItem!)
    }

    func resetInterval() {
        if rebufferingTimeoutWorkItem == nil {
            return
        }

        rebufferingTimeoutWorkItem?.cancel()
        rebufferingTimeoutWorkItem = nil
    }
}

protocol RebufferTimeoutListener: AnyObject {
    func onRebufferTimeout()
}
