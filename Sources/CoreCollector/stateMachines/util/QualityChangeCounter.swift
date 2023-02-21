import Foundation

public class QualityChangeCounter {
    private static var kAnalyticsQualityChangeThreshold = 50
    private static var kAnalyticsQualityChangeResetIntervalSeconds: TimeInterval = 60 * 60
    private static var kAnalyticsQualityChangeIntervalId = "com.bitmovin.analytics.core.utils.QualityChangeCounter"
    private var queue = DispatchQueue(label: QualityChangeCounter.kAnalyticsQualityChangeIntervalId)

    private var qualityResetWorkItem: DispatchWorkItem?
    private var qualityChangeCounter = 0

    func startInterval() {
        resetInterval()
        qualityResetWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.qualityChangeCounter = 0
        }
        queue.asyncAfter(deadline: .now() + QualityChangeCounter.kAnalyticsQualityChangeResetIntervalSeconds, execute: qualityResetWorkItem!)
    }

    func resetInterval() {
        if qualityResetWorkItem == nil {
            return
        }

        qualityResetWorkItem?.cancel()
        qualityResetWorkItem = nil
    }

    func increaseCounter() {
        if qualityChangeCounter == 0 {
            startInterval()
        }
        qualityChangeCounter += 1
    }

    var isQualityChangeEnabled: Bool {
        qualityChangeCounter <= QualityChangeCounter.kAnalyticsQualityChangeThreshold
    }
}
