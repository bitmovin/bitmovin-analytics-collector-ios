import Foundation

protocol EventDataDispatcher {
    func add(eventData: EventData)
    func addAd(adEventData: AdEventData)
    func disable()
    func resetSourceState()
}
