import Foundation

public class AdEventData: Codable {
    //  EventData data
    var audioCodec : String?
    var cdnProvider : String?
    var customData1: String?
    var customData2 : String?
    var customData3 : String?
    var customData4 : String?
    var customData5 : String?
    var customData6 : String?
    var customData7 : String?
    var customUserId : String?
    var customData8: String?
    var customData9: String?
    var customData10: String?
    var customData11: String?
    var customData12: String?
    var customData13: String?
    var customData14: String?
    var customData15: String?
    var customData16: String?
    var customData17: String?
    var customData18: String?
    var customData19: String?
    var customData20: String?
    var customData21: String?
    var customData22: String?
    var customData23: String?
    var customData24: String?
    var customData25: String?
    var domain : String?
    var experimentName: String?
    var key : String?
    var language: String?
    var path : String?
    var platform : String?
    var player: String?
    var playerKey: String?
    var playerTech: String?
    var screenHeight: Int?
    var screenWidth:Int?
    var userAgent: String?
    var userId : String?
    var version : String?
    var videoCodec: String?
    var videoId : String?
    var videoImpressionId: String?
    var videoTitle : String?
    var videoWindowHeight:Int?
    var videoWindowWidth:Int?
    
    //  AdBreak data
    var adFallbackIndex: Int = 0
    var adIdPlayer: String?
    var adIsPersistent: Bool?
    var adOffset: String?
    var adPosition: String?
    var adPreloadOffset: Int64?
    var adReplaceContentDuration: Int64?
    var adScheduleTime: Int64?
    var adTagType: String?
    var adTagUrl: String?
    var adTagServer: String?
    var adTagPath: String?
    
    //  AdSample data
    //    var timeHovered: Double?
    //    var timeInViewport: Double?
    //    var timeUntilHover: Double?
    var adPodPosition: Int?
    var adStartupTime: Int64?
    var clicked: Int = 0
    var clickPercentage: Int?
    var clickPosition: Int64?
    var closed: Int = 0
    var closePercentage: Int?
    var closePosition: Int64?
    var completed: Int = 0
    var errorCode: Int?
    var errorData: String?
    var errorMessage: String?
    var errorPercentage: Int?
    var errorPosition: Int64?
    var exitPosition: Int64?
    var midpoint: Int?
    var playPercentage: Int?
    var quartile1: Int = 0
    var quartile3: Int = 0
    var skipped: Int = 0
    var skipPercentage: Int?
    var skipPosition: Int64?
    var started: Int = 0
    var timeFromContent: Int64?
    var timePlayed: Int64?
    var timeToContent: Int64?
    
    // Ad data
    var adClickThroughUrl: String?
    var adDescription: String?
    var adDuration: Int64?
    var adId: String?
    var adPlaybackHeight: Int?
    var adPlaybackWidth: Int?
    var adSkippable: Bool?
    var adSkippableAfter: Int64?
    var adSystem: String?
    var adTitle: String?
    var advertiserName: String?
    var apiFramework: String?
    var creativeAdId: String?
    var creativeId: String?
    var dealId: String?
    var isLinear: Bool = false
    var mimeType: String?
    var mediaPath: String?
    var mediaServer: String?
    var mediaUrl: String?
    var minSuggestedDuration: Int64?
    var streamFormat: String?
    var surveyUrl: String?
    var universalAdIdRegistry: String?
    var universalAdIdValue: String?
    var videoBitrate: Int?
    var wrapperAdsCount: Int?
    
    var manifestDownloadTime: Int64?
    var analyticsVersion: String?
    var adModule: String?
    var adModuleVersion: String?
    var playerStartuptime: Int?
    var autoplay: Bool?
    var time: Int64?
    var adImpressionId: String?
    
    public func setEventData(eventData: EventData){
        self.analyticsVersion = eventData.analyticsVersion
        self.audioCodec = eventData.audioCodec
        self.cdnProvider = eventData.cdnProvider
        self.customData1 = eventData.customData1
        self.customData2 = eventData.customData2
        self.customData3 = eventData.customData3
        self.customData4 = eventData.customData4
        self.customData5 = eventData.customData5
        self.customData6 = eventData.customData6
        self.customData7 = eventData.customData7
        self.customData8 = eventData.customData8
        self.customData9 = eventData.customData9
        self.customData10 = eventData.customData10
        self.customData11 = eventData.customData11
        self.customData12 = eventData.customData12
        self.customData13 = eventData.customData13
        self.customData14 = eventData.customData14
        self.customData15 = eventData.customData15
        self.customData16 = eventData.customData16
        self.customData17 = eventData.customData17
        self.customData18 = eventData.customData18
        self.customData19 = eventData.customData19
        self.customData20 = eventData.customData20
        self.customData21 = eventData.customData21
        self.customData22 = eventData.customData22
        self.customData23 = eventData.customData23
        self.customData24 = eventData.customData24
        self.customData25 = eventData.customData25
        self.customUserId = eventData.customUserId
        self.domain = eventData.domain
        self.experimentName = eventData.experimentName
        self.key = eventData.key
        self.language = eventData.language
        self.path = eventData.path
        self.platform = eventData.platform
        self.player = eventData.player
        self.playerKey = eventData.playerKey
        self.playerTech = eventData.playerTech
        self.screenHeight = eventData.screenHeight
        self.screenWidth = eventData.screenWidth
        self.userAgent = eventData.userAgent
        self.userId = eventData.userId
        self.version = eventData.version
        self.videoCodec = eventData.videoCodec
        self.videoId = eventData.videoId
        self.videoTitle = eventData.videoTitle
        self.videoWindowHeight = eventData.videoWindowHeight
        self.videoWindowWidth = eventData.videoWindowWidth
        self.videoImpressionId = eventData.impressionId
    }
    
    public func setAdBreak(adBreak: AnalyticsAdBreak){
        self.adFallbackIndex = adBreak.fallbackIndex
        self.adIsPersistent = adBreak.persistent
        self.adIdPlayer = adBreak.id
        self.adPosition = adBreak.position?.rawValue
        self.adOffset = adBreak.offset
        self.adPreloadOffset = adBreak.preloadOffset
        self.adReplaceContentDuration = adBreak.replaceContentDuration?.milliseconds
        self.adScheduleTime = adBreak.scheduleTime?.milliseconds
        (self.adTagServer, self.adTagPath) = Util.getHostNameAndPath(uriString: adBreak.tagUrl)
        self.adTagType = adBreak.tagType?.rawValue
        self.adTagUrl = adBreak.tagUrl
    }
    
    public func setAdSample(adSample: AdSample){
        self.adPodPosition = adSample.adPodPosition
        self.adStartupTime = adSample.adStartupTime?.milliseconds
        self.clicked = adSample.clicked
        self.clickPercentage = adSample.clickPercentage
        self.clickPosition = adSample.clickPosition?.milliseconds
        self.closed = adSample.closed
        self.closePercentage = adSample.closePercentage
        self.closePosition = adSample.closePosition?.milliseconds
        self.completed = adSample.completed
        self.errorCode = adSample.errorCode
        self.errorData  = adSample.errorData
        self.errorMessage = adSample.errorMessage
        self.errorPercentage = adSample.errorPercentage
        self.errorPosition = adSample.errorPosition?.milliseconds
        self.exitPosition = adSample.exitPosition?.milliseconds
        self.midpoint = adSample.midpoint
        self.playPercentage = adSample.playPercentage
        self.quartile1 = adSample.quartile1
        self.quartile3 = adSample.quartile3
        self.skipped = adSample.skipped
        self.skipPercentage = adSample.skipPercentage
        self.skipPosition = adSample.skipPosition?.milliseconds
        self.started = adSample.started
        self.timeFromContent = adSample.timeFromContent?.milliseconds
        self.timePlayed = adSample.timePlayed?.milliseconds
        self.timeToContent = adSample.timeToContent?.milliseconds
        
        setAd(ad: adSample.ad)
    }
    
    private func setAd(ad: AnalyticsAd){
        self.adClickThroughUrl = ad.clickThroughUrl
        self.adDescription = ad.description
        self.adDuration =  ad.duration?.milliseconds
        self.adId = ad.id
        self.adPlaybackHeight = ad.height
        self.adPlaybackWidth = ad.width
        self.adSkippable = ad.skippable
        self.adSkippableAfter =  ad.skippableAfter?.milliseconds
        self.adSystem = ad.adSystemName
        self.adTitle = ad.title
        self.advertiserName = ad.advertiserName
        self.apiFramework = ad.apiFramework
        self.creativeAdId = ad.creativeAdId
        self.creativeId = ad.creativeId
        self.dealId = ad.dealId
        self.isLinear = ad.isLinear
        (self.mediaServer, self.mediaPath) = Util.getHostNameAndPath(uriString: ad.mediaFileUrl)
        self.mediaUrl = ad.mediaFileUrl
        self.minSuggestedDuration = ad.minSuggestedDuration?.milliseconds
        self.streamFormat = ad.mimeType
        self.surveyUrl = ad.surveyUrl
        self.universalAdIdRegistry = ad.universalAdIdRegistry
        self.universalAdIdValue = ad.universalAdIdValue
        self.videoBitrate = ad.bitrate
        self.wrapperAdsCount = ad.wrapperAdsCount
    }
}
