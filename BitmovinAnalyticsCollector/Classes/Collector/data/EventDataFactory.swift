import AVFoundation
import Foundation

class EventDataFactory {
    private final var stateMachine: StateMachine
    private final var config: BitmovinAnalyticsConfig
    private var playerAdapter: PlayerAdapter?
    
    internal var didSendDrmLoadTime = false
    
    init(_ stateMachine: StateMachine, _ config: BitmovinAnalyticsConfig) {
        self.stateMachine = stateMachine
        self.config = config
    }
    
    func useAdapter(playerAdapter: PlayerAdapter) {
        self.playerAdapter = playerAdapter
    }
    
    func removeAdapter() {
        self.playerAdapter = nil
    }
    
    func createEventData() -> EventData {
        let eventData = EventData(config: config, sourceMetadata: playerAdapter?.currentSourceMetadata, impressionId: stateMachine.impressionId)
        playerAdapter?.decorateEventData(eventData: eventData)
        eventData.state = stateMachine.state.rawValue

        if !self.didSendDrmLoadTime,  let drmLoadTime = playerAdapter?.drmDownloadTime {
            self.didSendDrmLoadTime = true
            eventData.drmLoadTime = drmLoadTime
        }

        if let timeStart = stateMachine.videoTimeStart, CMTIME_IS_NUMERIC(_: timeStart) {
            eventData.videoTimeStart = Int64(CMTimeGetSeconds(timeStart) * BitmovinAnalyticsInternal.msInSec)
        }
        if let timeEnd = stateMachine.videoTimeEnd, CMTIME_IS_NUMERIC(_: timeEnd) {
            eventData.videoTimeEnd = Int64(CMTimeGetSeconds(timeEnd) * BitmovinAnalyticsInternal.msInSec)
        }
        
        //play attempt failed
        if (stateMachine.videoStartFailed) {
            eventData.videoStartFailed = stateMachine.videoStartFailed
            eventData.videoStartFailedReason = stateMachine.videoStartFailedReason ?? VideoStartFailedReason.unknown
            stateMachine.resetVideoStartFailed()
        }
        return eventData
    }
}
