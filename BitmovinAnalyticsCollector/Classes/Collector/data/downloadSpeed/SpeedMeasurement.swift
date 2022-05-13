import Foundation

public struct SpeedMeasurement {
    
    public init() {}
    
    // Download time in milliseconds
    public var duration: Int64 = 0

    // Bytes downloaded
    public var size: Int64 = 0
    
    // amount of segments downloaded
    public var segmentCount: Int = 0
}
