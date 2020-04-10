import CoreMedia
import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
    func destroy()
    var currentTime: CMTime? { get }
}
