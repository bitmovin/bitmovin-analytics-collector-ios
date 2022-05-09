public class DownloadSpeedInfoDto: Codable {

    // Number of completed segment downloads
    var segmentsDownloadCount: Int = 0

    // Total download size in bytes
    var segmentsDownloadSize: Int64 = 0

    // Total time spent downloading segments in milliseconds
    var segmentsDownloadTime: Int64 = 0
}
