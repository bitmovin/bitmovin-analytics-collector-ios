import AVFoundation
import Foundation

internal class BitrateDetectionService: NSObject {
    private static let heartbeatIntervalSec: Double = 1.0

    @objc private(set) dynamic var videoBitrate: Double = 0

    private var accessLogProvider: AccessLogProvider?
    private weak var heartbeatTimer: Timer?

    func startMonitoring(accessLogProvider: AccessLogProvider) {
        self.accessLogProvider = accessLogProvider
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(
            timeInterval: BitrateDetectionService.heartbeatIntervalSec,
            target: self,
            selector: #selector(BitrateDetectionService.detectBitrateChange),
            userInfo: nil,
            repeats: true
        )
    }

    func stopMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        accessLogProvider = nil
    }

    func resetSourceState() {
        videoBitrate = 0
    }

    @objc
    func detectBitrateChange() {
        guard let currentLogEntry = getCurrentLogEntry() else {
            return
        }

        if currentLogEntry.indicatedBitrate <= 0 {
            return
        }

        if currentLogEntry.indicatedBitrate == videoBitrate {
            return
        }

        // This will trigger outside key-value-observation (KVO)
        videoBitrate = currentLogEntry.indicatedBitrate
    }

    /*
     returns the last AccessLogEntry with durationWatched > 0
     for us this is the current relevant entry
     */
    private func getCurrentLogEntry() -> AccessLogDto? {
        guard let events = accessLogProvider?.getEvents() else {
            return nil
        }

        if events.isEmpty {
            return nil
        }

        let index = events.lastIndex { event in
            event.durationWatched > 0
        }

        guard let index = index else {
            return nil
        }

        return events[index]
    }
}
