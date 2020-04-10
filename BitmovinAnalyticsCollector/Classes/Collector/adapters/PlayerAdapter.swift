import CoreMedia
import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
    func stopMonitoring()
    func destroy()
    var currentTime: CMTime? { get }
}
