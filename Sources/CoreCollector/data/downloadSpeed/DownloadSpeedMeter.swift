import Foundation

public class DownloadSpeedMeter {
    private let downloadSpeedMeterDispatchQueue = DispatchQueue(
        label: "bitmovin.analytics.AVPlayerCollector.DownloadSpeedMeterQueue"
    )
    private(set) var measures: [SpeedMeasurement] = []

    public init() {}

    public func add(measurement: SpeedMeasurement) {
        downloadSpeedMeterDispatchQueue.sync {
            measures.append(measurement)
        }
    }

    public func getInfoAndReset() -> DownloadSpeedInfoDto {
        let info = DownloadSpeedInfoDto()
        downloadSpeedMeterDispatchQueue.sync {
            let sumSpeed = measures.reduce(into: SpeedMeasurement()) { result, mes in result += mes }
            info.segmentsDownloadCount = sumSpeed.numberOfSegmentsDownloaded
            info.segmentsDownloadSize = sumSpeed.numberOfBytesTransferred
            info.segmentsDownloadTime = sumSpeed.downloadTime
            measures.removeAll()
        }
        return info
    }
}
