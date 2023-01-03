import Foundation

internal class SequenceNumberDispatcher: EventDataDispatcher {
    
    private var sequenceNumber: Int32 = 0
    
    private let innerDispatcher: EventDataDispatcher
    
    init(innerDispatcher: EventDataDispatcher) {
        self.innerDispatcher = innerDispatcher
    }
    
    func add(_ eventData: EventData) {
        eventData.sequenceNumber = self.sequenceNumber
        self.sequenceNumber += 1
        
        innerDispatcher.add(eventData)
    }
    
    func addAd(_ adEventData: AdEventData) {
        innerDispatcher.addAd(adEventData)
    }
    
    func disable() {
        self.sequenceNumber = 0
        innerDispatcher.disable()
    }
    
    func resetSourceState() {
        self.sequenceNumber = 0
        innerDispatcher.resetSourceState()
    }
    
}
