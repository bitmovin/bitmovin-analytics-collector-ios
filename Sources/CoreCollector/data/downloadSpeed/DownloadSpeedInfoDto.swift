import Foundation

public class DownloadSpeedInfoDto: Codable {
    public init() {}

    // Number of completed segment downloads
    public var segmentsDownloadCount: Int = 0

    // Total download size in bytes
    public var segmentsDownloadSize: Int64 = 0

    // Total time spent downloading segments in milliseconds
    public var segmentsDownloadTime: Int64 = 0
}
