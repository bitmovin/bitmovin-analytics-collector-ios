import Foundation

public class DownloadSpeedMeter {
    private let downloadSpeedMeterDispatchQueue: DispatchQueue
    private(set) var measures: [SpeedMeasurement] = []
    
    public init() {
        self.downloadSpeedMeterDispatchQueue = DispatchQueue(label: "bitmovin.analytics.AVPlayerCollector.DownloadSpeedMeterQueue")
    }
    
    public func add(measurement:SpeedMeasurement) {
        downloadSpeedMeterDispatchQueue.sync {
            measures.append(measurement)
        }
    }
    
    public func getInfoAndReset() -> DownloadSpeedInfoDto {
        let info = DownloadSpeedInfoDto()
        downloadSpeedMeterDispatchQueue.sync {
            info.segmentsDownloadCount = measures.reduce(into: 0) { result, m in result += m.segmentCount}
            info.segmentsDownloadSize = measures.reduce(into: 0) { result, m in result += m.size}
            info.segmentsDownloadTime = measures.reduce(into: 0) { result, m in result += m.duration}
            measures.removeAll()
        }
        return info
    }
}
