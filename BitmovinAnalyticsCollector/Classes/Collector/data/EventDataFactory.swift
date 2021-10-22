import AVFoundation
import Foundation

class EventDataFactory {
    private final var config: BitmovinAnalyticsConfig
    private final var userIdProvider: UserIdProvider
    
    init(_ config: BitmovinAnalyticsConfig, _ userIdProvider: UserIdProvider) {
        self.config = config
        self.userIdProvider = userIdProvider
    }
    
    func createEventData(_ state: String, _ impressionId: String, _ videoTimeStart: CMTime?, _ videoTimeEnd: CMTime?, _ drmLoadTime: Int64?, _ sourceMetaData: SourceMetadata?) -> EventData {
        let eventData = EventData(impressionId)
        
        eventData.state = state
        eventData.drmLoadTime = drmLoadTime
        setBasicData(eventData)
        setAnalyticsVersion(eventData)
        setConfigData(eventData, sourceMetaData)
        setVideoTime(eventData, videoTimeStart, videoTimeEnd)
        return eventData
    }
    
    private func setBasicData(_ eventData: EventData) {
        eventData.version = UIDevice.current.systemVersion
        
        eventData.userId = userIdProvider.getUserId()
        eventData.userAgent = Util.userAgent()
        eventData.domain = Util.mainBundleIdentifier()
        eventData.language = Util.language()
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
            eventData.customData8 = metadata.customData8
            eventData.customData9 = metadata.customData9
            eventData.customData10 = metadata.customData10
            eventData.customData11 = metadata.customData11
            eventData.customData12 = metadata.customData12
            eventData.customData13 = metadata.customData13
            eventData.customData14 = metadata.customData14
            eventData.customData15 = metadata.customData15
            eventData.customData16 = metadata.customData16
            eventData.customData17 = metadata.customData17
            eventData.customData18 = metadata.customData18
            eventData.customData19 = metadata.customData19
            eventData.customData20 = metadata.customData20
            eventData.customData21 = metadata.customData21
            eventData.customData22 = metadata.customData22
            eventData.customData23 = metadata.customData23
            eventData.customData24 = metadata.customData24
            eventData.customData25 = metadata.customData25
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
            eventData.customData8 = config.customData8
            eventData.customData9 = config.customData9
            eventData.customData10 = config.customData10
            eventData.customData11 = config.customData11
            eventData.customData12 = config.customData12
            eventData.customData13 = config.customData13
            eventData.customData14 = config.customData14
            eventData.customData15 = config.customData15
            eventData.customData16 = config.customData16
            eventData.customData17 = config.customData17
            eventData.customData18 = config.customData18
            eventData.customData19 = config.customData19
            eventData.customData20 = config.customData20
            eventData.customData21 = config.customData21
            eventData.customData22 = config.customData22
            eventData.customData23 = config.customData23
            eventData.customData24 = config.customData24
            eventData.customData25 = config.customData25
            eventData.videoId = config.videoId
            eventData.videoTitle = config.title
            eventData.experimentName = config.experimentName
            eventData.path = config.path
        }
    }
    
    private func setVideoTime(_ eventData: EventData, _ videoTimeStart: CMTime?, _ videoTimeEnd: CMTime?) {
        if let timeStart = videoTimeStart, CMTIME_IS_NUMERIC(_: timeStart) {
            eventData.videoTimeStart = Int64(CMTimeGetSeconds(timeStart) * BitmovinAnalyticsInternal.msInSec)
        }
        if let timeEnd = videoTimeEnd, CMTIME_IS_NUMERIC(_: timeEnd) {
            eventData.videoTimeEnd = Int64(CMTimeGetSeconds(timeEnd) * BitmovinAnalyticsInternal.msInSec)
        }
    }
}
