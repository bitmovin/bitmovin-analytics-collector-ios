import Foundation
import AVFoundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

internal class DownloadSpeedDetectionService: NSObject {
    private static let segmentsDownloadTimeMinThreshold: Int = 200
    private static let heartbeatInterval: Double = 1.0
    private static let SECONDS: Int64 = 1000
    
    private let accessLogProvider: AccessLogProvider
    private let downloadSpeedMeter: DownloadSpeedMeter
    
    weak private var heartbeatTimer: Timer?
    
    private var prevAccessLog: [AccessLogDto]? = nil
    private var timestamp: Int64? = nil
    
    init(accessLogProvider: AccessLogProvider, downloadSpeedMeter: DownloadSpeedMeter) {
        self.accessLogProvider = accessLogProvider
        self.downloadSpeedMeter = downloadSpeedMeter
    }
    
    func startMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: DownloadSpeedDetectionService.heartbeatInterval, target: self, selector: #selector(DownloadSpeedDetectionService.detectDownloadSpeed), userInfo: nil, repeats: true)
    }
    
    func stopMonitoring() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    @objc public func detectDownloadSpeed() {
        guard let currentLogs = accessLogProvider.getEvents() else {
            return
        }
        
        let speedMeasurement = createSpeedMeasurement(prevAccessLog ?? [], currentLogs)
        
        
        if !isValid(speedMeasurement: speedMeasurement) {
            return
        }
        
        prevAccessLog = currentLogs
        downloadSpeedMeter.add(measurement: speedMeasurement)
    }
    
    private func createSpeedMeasurement(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto]) -> SpeedMeasurement {
        let speedMeasurement = SpeedMeasurement()
        speedMeasurement.duration = Int64(DownloadSpeedDetectionService.heartbeatInterval) * DownloadSpeedDetectionService.SECONDS
        
        if prevLogs.count > 0 {
            for i in 0...prevLogs.count-1 {
                let prevLog = prevLogs[i]
                let currentLog = currentLogs[i]
                speedMeasurement.size += currentLog.numberofBytesTransfered - prevLog.numberofBytesTransfered
                speedMeasurement.segmentCount += currentLog.numberOfMediaRequests - prevLog.numberOfMediaRequests
            }
        }
        
        if prevLogs.count < currentLogs.count {
            for i in prevLogs.count...currentLogs.count-1 {
                let currentLog = currentLogs[i]
                speedMeasurement.size += currentLog.numberofBytesTransfered
                speedMeasurement.segmentCount += currentLog.numberOfMediaRequests
            }
        }
        return speedMeasurement
    }
    
    private func isValid(speedMeasurement: SpeedMeasurement) -> Bool {
        // consider negative values as invalid
        if speedMeasurement.size < 0
            || speedMeasurement.segmentCount < 0
            || speedMeasurement.duration < 0 {
            return false
        }
        
        // no data no tracking
        if speedMeasurement.size == 0 {
            return false
        }
        
        return true
    }
}
