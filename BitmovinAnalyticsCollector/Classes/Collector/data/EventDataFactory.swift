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
        let eventData = EventData()
        eventData.version = UIDevice.current.systemVersion
        
        eventData.userId = Util.getUserId()
        eventData.userAgent = Util.userAgent()
        eventData.domain = Util.mainBundleIdentifier()
        eventData.language = Util.language()
        
        setAnalyticsVersion(eventData)
        setConfigData(eventData, playerAdapter?.currentSourceMetadata)
        setValuesFromStateMachine(eventData)
        setDrmLoadTime(eventData, playerAdapter?.drmDownloadTime)
        setVideoTime(eventData)
        setVideoStartupFailed(eventData)
        
        playerAdapter?.decorateEventData(eventData: eventData)
        return eventData
    }
    
    private func setAnalyticsVersion(_ eventData: EventData) {
        if let text = Bundle(for: type(of: self)).infoDictionary?["CFBundleShortVersionString"] as? String {
            eventData.analyticsVersion = text
        }
    }
    
    private func setConfigData(_ eventData: EventData, _ sourceMetadata: SourceMetadata?){
        eventData.key = config.key
        eventData.playerKey = config.playerKey
        eventData.customUserId = config.customerUserId
        
        if let metadata = sourceMetadata {
            eventData.cdnProvider = metadata.cdnProvider
            eventData.customData1 = metadata.customData1
            eventData.customData2 = metadata.customData2
            eventData.customData3 = metadata.customData3
            eventData.customData4 = metadata.customData4
            eventData.customData5 = metadata.customData5
            eventData.customData6 = metadata.customData6
            eventData.customData7 = metadata.customData7
            eventData.videoId = metadata.videoId
            eventData.videoTitle = metadata.title
            eventData.experimentName = metadata.experimentName
            eventData.path = metadata.path
        }
        else {
            eventData.cdnProvider = config.cdnProvider
            eventData.customData1 = config.customData1
            eventData.customData2 = config.customData2
            eventData.customData3 = config.customData3
            eventData.customData4 = config.customData4
            eventData.customData5 = config.customData5
            eventData.customData6 = config.customData6
            eventData.customData7 = config.customData7
            eventData.videoId = config.videoId
            eventData.videoTitle = config.title
            eventData.experimentName = config.experimentName
            eventData.path = config.path
        }
    }
    private func setValuesFromStateMachine(_ eventData: EventData) {
        eventData.state = stateMachine.state.rawValue
        eventData.impressionId = stateMachine.impressionId
    }
    
    private func setDrmLoadTime(_ eventData: EventData, _ drmLoadTime: Int64?) {
        if self.didSendDrmLoadTime {
            return
        }
        
        if drmLoadTime == nil  {
            return
        }
        
        self.didSendDrmLoadTime = true
        eventData.drmLoadTime = drmLoadTime
    }
    
    private func setVideoTime(_ eventData: EventData) {
        if let timeStart = stateMachine.videoTimeStart, CMTIME_IS_NUMERIC(_: timeStart) {
            eventData.videoTimeStart = Int64(CMTimeGetSeconds(timeStart) * BitmovinAnalyticsInternal.msInSec)
        }
        if let timeEnd = stateMachine.videoTimeEnd, CMTIME_IS_NUMERIC(_: timeEnd) {
            eventData.videoTimeEnd = Int64(CMTimeGetSeconds(timeEnd) * BitmovinAnalyticsInternal.msInSec)
        }
    }
    
    private func setVideoStartupFailed(_ eventData: EventData) {
        if (!stateMachine.videoStartFailed) {
            return
        }
        
        eventData.videoStartFailed = stateMachine.videoStartFailed
        eventData.videoStartFailedReason = stateMachine.videoStartFailedReason ?? VideoStartFailedReason.unknown
        stateMachine.resetVideoStartFailed()
    }
}
