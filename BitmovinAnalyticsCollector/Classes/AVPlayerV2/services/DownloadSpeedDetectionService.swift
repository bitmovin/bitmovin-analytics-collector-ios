import Foundation
import AVFoundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

internal class DownloadSpeedDetectionService: NSObject {
    private let accessLogProvider: AccessLogProvider
    private var accessLog: [AccessLogDto]? = nil
    private var timestamp: Int64? = nil
    
    init(accessLogProvider: AccessLogProvider) {
        self.accessLogProvider = accessLogProvider
    }
    
    func resetSourceState() {
        accessLog = nil
        timestamp = nil
    }
    
    func getDownloadSpeedInfo() -> DownloadSpeedInfoDto? {
        guard let prevLogs = accessLog else {
            return nil
        }
        
        guard let currentLogs = accessLogProvider.getEvents() else {
            return nil
        }
        
        guard let prevTimestamp = timestamp else {
            return nil
        }
        
        return calculateDownloadInfo(prevLogs, currentLogs, prevTimestamp)
    }
    
    private func calculateDownloadInfo(_ prevLogs: [AccessLogDto], _ currentLogs: [AccessLogDto], _ prevTimestamp: Int64) -> DownloadSpeedInfoDto? {
        let downloadSpeedInfo = DownloadSpeedInfoDto()
        downloadSpeedInfo.segmentsDownloadTime = Date().timeIntervalSince1970Millis - prevTimestamp
        
        if (prevLogs.count <= 0 || currentLogs.count <= 0) {
            return nil
        }
        
        for i in 0...prevLogs.count-1 {
            let prevLog = prevLogs[i]
            let currentLog = currentLogs[i]
            downloadSpeedInfo.segmentsDownloadSize += currentLog.numberofBytesTransfered - prevLog.numberofBytesTransfered
            downloadSpeedInfo.segmentsDownloadCount += currentLog.numberOfMediaRequests - prevLog.numberOfMediaRequests
        }
        if (prevLogs.count < currentLogs.count) {
            for i in prevLogs.count-1...currentLogs.count-1 {
                let currentLog = currentLogs[i]
                downloadSpeedInfo.segmentsDownloadSize += currentLog.numberofBytesTransfered
                downloadSpeedInfo.segmentsDownloadCount += currentLog.numberOfMediaRequests
            }
        }
        return downloadSpeedInfo
    }
    
    /*
     saves the current state of the accessLog
     */
    func saveSnapshot() {
        accessLog = accessLogProvider.getEvents()
        timestamp = Date().timeIntervalSince1970Millis
    }
}
