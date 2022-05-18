import Foundation

public struct SpeedMeasurement {
    public init() {}
    
    public var downloadTime: Int64 = 0

    public var numberOfBytesTransferred: Int64 = 0
    
    public var numberOfSegmentsDownloaded: Int = 0
    
}

extension SpeedMeasurement {
    public static func + (left: SpeedMeasurement, right: SpeedMeasurement) -> SpeedMeasurement {
        var new = SpeedMeasurement()
        new.downloadTime = left.downloadTime + right.downloadTime
        new.numberOfBytesTransferred = left.numberOfBytesTransferred + right.numberOfBytesTransferred
        new.numberOfSegmentsDownloaded = left.numberOfSegmentsDownloaded + right.numberOfSegmentsDownloaded
        return new
    }
    
    public static func += (left: inout SpeedMeasurement, right: SpeedMeasurement) {
        left = left + right
    }
}
