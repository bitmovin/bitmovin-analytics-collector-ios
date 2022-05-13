import Foundation

public class DownloadSpeedMeter {
    private(set) var measures: [SpeedMeasurement] = []
    
    public init() {}
    
    public func reset() {
        measures.removeAll()
    }
    
    public func add(measurement:SpeedMeasurement) {
        measures.append(measurement)
    }
    
    
    public func getInfo() -> DownloadSpeedInfoDto {
        let info = DownloadSpeedInfoDto()
        info.segmentsDownloadCount = measures.reduce(into: 0) { result, m in result += m.segmentCount}
        info.segmentsDownloadSize = measures.reduce(into: 0) { result, m in result += m.size}
        info.segmentsDownloadTime = measures.reduce(into: 0) { result, m in result += m.duration}
        return info
    }
}
