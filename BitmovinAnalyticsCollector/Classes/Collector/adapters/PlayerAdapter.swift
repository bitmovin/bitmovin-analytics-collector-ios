import CoreMedia
import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
    var currentTime: CMTime? { get }
}
