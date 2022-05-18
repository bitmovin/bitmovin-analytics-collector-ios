import Foundation
import AVFoundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

internal class DownloadSpeedDetectionService: NSObject {
    
    private enum DownloadSpeedDetectionError: Error {
        case invalidMeasurement
    }
    
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
        prevAccessLog = nil
    }
    
    @objc public func detectDownloadSpeed() {
        guard let currentLogs = accessLogProvider?.getEvents() else {
            return
        }
        
        // in the rare case that the currentLog is smaller than the previous one we skip downloadSpeed Calculation
        //      the problem is that log entries in the accesslog are deleted in some cases, which leads to issues.
        //      Our calculation is assuming that the log is only growing and not shrinking.
        //      when we encounter such an issue we will not calculate the downloaded bytes delta and
        //      just use the current logs for the next calculation.
        guard currentLogs.count >= prevAccessLog?.count ?? 0 else {
            // recover the previousLogs
            prevAccessLog = currentLogs
            return
        }
        
        var speedMeasurement: SpeedMeasurement
        do {
            speedMeasurement = try createSpeedMeasurement(prevAccessLog ?? [], currentLogs)
        } catch {
            // recover the previousLogs
            prevAccessLog = currentLogs
            return
        }
        
        if !isValid(speedMeasurement: speedMeasurement) {
            return
        }
        
        // no data no tracking
        if speedMeasurement.numberOfBytesTransferred == 0 {
            return
        }
        
        prevAccessLog = currentLogs
        downloadSpeedMeter.add(measurement: speedMeasurement)
    }
    
    private func createSpeedMeasurement(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto]) throws -> SpeedMeasurement {
        let deltaSpeedExisting = try calcForExistingValues(prevLogs, currentLogs)
        let newSpeed = calcForNewValues(prevLogs, currentLogs)
        
        var speedMeasurement = newSpeed + deltaSpeedExisting
        speedMeasurement.downloadTime = DownloadSpeedDetectionService.heartbeatIntervalMs
        return speedMeasurement
    }
    
    /**
     gathers download information of log entries present in both lists - previous logs and current logs
    - Returns: aggregated delta speed measurement of existing log entries
    - Throws: `DownloadSpeedDetectionError.invalidMeasurement` when any measurements delta is invalid
     */
    private func calcForExistingValues(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto]) throws -> SpeedMeasurement {
        guard prevLogs.count > 0 else {
            return SpeedMeasurement()
        }
        
        var deltaSpeed = SpeedMeasurement()
        for i in 0...prevLogs.count-1 {
            let prevLog = prevLogs[i]
            let currentLog = currentLogs[i]
            
            var measure = SpeedMeasurement()
            measure.numberOfBytesTransferred += currentLog.numberofBytesTransferred - prevLog.numberofBytesTransferred
            measure.numberOfSegmentsDownloaded += currentLog.numberOfMediaRequests - prevLog.numberOfMediaRequests
            
            if !isValid(speedMeasurement: measure) {
                throw DownloadSpeedDetectionError.invalidMeasurement
            }
            
            deltaSpeed += measure
        }
        return deltaSpeed
    }
    
    /**
    gathers download information of new entries only present in currentLogs
    - Returns: aggregated spead measurement for new log entries
     */
    private func calcForNewValues(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto]) -> SpeedMeasurement {
        guard currentLogs.count > prevLogs.count else {
            return SpeedMeasurement()
        }
        
        var newSpeed = SpeedMeasurement()
        for i in prevLogs.count...currentLogs.count-1 {
            let currentLog = currentLogs[i]
            newSpeed.numberOfBytesTransferred += currentLog.numberofBytesTransferred
            newSpeed.numberOfSegmentsDownloaded += currentLog.numberOfMediaRequests
        }
        
        return newSpeed
    }
    
    private func isValid(speedMeasurement: SpeedMeasurement) -> Bool {
        // consider negative values as invalid
        return speedMeasurement.numberOfBytesTransferred >= 0
        && speedMeasurement.numberOfSegmentsDownloaded >= 0
        && speedMeasurement.downloadTime >= 0
    }
}
