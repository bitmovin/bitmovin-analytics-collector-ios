import CoreMedia
import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
    func stopMonitoring()
    func destroy()
    var drmDownloadTime: Int64? { get }
    var currentTime: CMTime? { get }
}
