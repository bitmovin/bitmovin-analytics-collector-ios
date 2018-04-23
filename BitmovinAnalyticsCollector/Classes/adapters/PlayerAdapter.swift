
import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
}
