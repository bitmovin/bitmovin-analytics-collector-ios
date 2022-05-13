import Foundation

public struct SpeedMeasurement {
    public init() {}
    
    public var downloadTime: Int64 = 0

    public var numberOfBytesTransferred: Int64 = 0
    
    public var numberOfSegmentsDownloaded: Int = 0
}
