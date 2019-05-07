import Foundation
import CoreMedia

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
    var currentTime: CMTime { get }
}
