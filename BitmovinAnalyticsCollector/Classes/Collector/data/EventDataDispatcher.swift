import Foundation

protocol EventDataDispatcher {
    func add(eventData: EventData)
    func enable()
    func disable()
    func clear()
}
