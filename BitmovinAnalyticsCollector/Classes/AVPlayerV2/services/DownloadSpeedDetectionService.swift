import Foundation
import AVFoundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

internal class DownloadSpeedDetectionService: NSObject {
    private static let segmentsDownloadTimeMinThreshold: Int = 200
    private static let heartbeatIntervalMs: Int64 = 1000
    
    private var accessLogProvider: AccessLogProvider?
    private let downloadSpeedMeter: DownloadSpeedMeter
    
    weak private var heartbeatTimer: Timer?
    
    private var prevAccessLog: [AccessLogDto]? = nil
    private var timestamp: Int64? = nil
    
    init(downloadSpeedMeter: DownloadSpeedMeter) {
        self.downloadSpeedMeter = downloadSpeedMeter
    }
    
    func startMonitoring(accessLogProvider: AccessLogProvider) {
        self.accessLogProvider = accessLogProvider
        heartbeatTimer?.invalidate()
        let heartbeatSec = Double(DownloadSpeedDetectionService.heartbeatIntervalMs) / 1000
        heartbeatTimer = Timer.scheduledTimer(timeInterval: heartbeatSec, target: self, selector: #selector(DownloadSpeedDetectionService.detectDownloadSpeed), userInfo: nil, repeats: true)
    }
    
    func stopMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        accessLogProvider = nil
    }
    
    @objc public func detectDownloadSpeed() {
        guard let currentLogs = accessLogProvider?.getEvents() else {
            return
        }
        
        let speedMeasurement = createSpeedMeasurement(prevAccessLog ?? [], currentLogs)
        
        
        if !isValid(speedMeasurement: speedMeasurement) {
            return
        }
        
        // no data no tracking
        if speedMeasurement.numberOfBytesTransfered == 0 {
            return
        }
        
        print("DownloadSpeedDetectionService: accessLog size:\(currentLogs.count)")
        prevAccessLog = currentLogs
        downloadSpeedMeter.add(measurement: speedMeasurement)
    }
    
    private func createSpeedMeasurement(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto]) -> SpeedMeasurement {
        var speedMeasurement = SpeedMeasurement()
        speedMeasurement.downloadTime = DownloadSpeedDetectionService.heartbeatIntervalMs
        
        if prevLogs.count > 0 {
            for i in 0...prevLogs.count-1 {
                let prevLog = prevLogs[i]
                let currentLog = currentLogs[i]
                speedMeasurement.numberOfBytesTransfered += currentLog.numberofBytesTransfered - prevLog.numberofBytesTransfered
                speedMeasurement.numberOfSegmentsDownloaded += currentLog.numberOfMediaRequests - prevLog.numberOfMediaRequests
            }
        }
        
        if prevLogs.count < currentLogs.count {
            for i in prevLogs.count...currentLogs.count-1 {
                let currentLog = currentLogs[i]
                speedMeasurement.numberOfBytesTransfered += currentLog.numberofBytesTransfered
                speedMeasurement.numberOfSegmentsDownloaded += currentLog.numberOfMediaRequests
            }
        }
        return speedMeasurement
    }
    
    private func isValid(speedMeasurement: SpeedMeasurement) -> Bool {
        // consider negative values as invalid
        return speedMeasurement.numberOfBytesTransfered >= 0
            && speedMeasurement.numberOfSegmentsDownloaded >= 0
            && speedMeasurement.downloadTime >= 0
    }
}
