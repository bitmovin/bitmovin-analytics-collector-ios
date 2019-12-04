//
//  AdEventData.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

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
    var adFallbackIndex: Double = 0
    var adIdPlayer: String?
    var adIsPersistent: Bool?
    var adOffset: String?
    var adPosition: String?
    var adPreloadOffset: Double?
    var adReplaceContentDuration: Double?
    var adScheduleTime: Double?
    var adTagType: String?
    var adTagUrl: String?
    var adTagServer: String?
    var adTagPath: String?
    
    //  AdSample data
    //    var timeHovered: Double?
    //    var timeInViewport: Double?
    //    var timeUntilHover: Double?
    var adPodPosition: Int?
    var adStartupTime: Double?
    var clicked: Double = 0
    var clickPercentage: Int?
    var clickPosition: Double?
    var closed: Double = 0
    var closePercentage: Int?
    var closePosition: Double?
    var completed: Double = 0
    var errorCode: Int?
    var errorData: String?
    var errorMessage: String?
    var errorPercentage: Int?
    var errorPosition: Double?
    var exitPosition: Double?
    var midpoint: Double?
    var playPercentage: Int?
    var quartile1: Double = 0
    var quartile3: Double = 0
    var skipped: Double = 0
    var skipPercentage: Int?
    var skipPosition: Double?
    var started: Double = 0
    var timeFromContent: Double?
    var timePlayed: Double?
    var timeToContent: Double?
    
    // Ad data
    var adClickThroughUrl: String?
    var adDescription: String?
    var adDuration: Double?
    var adId: String?
    var adPlaybackHeight: Int?
    var adPlaybackWidth: Int?
    var adSkippable: Bool?
    var adSkippableAfter: Double?
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
    var minSuggestedDuration: Double?
    var streamFormat: String?
    var surveyUrl: String?
    var universalAdIdRegistry: String?
    var universalAdIdValue: String?
    var videoBitrate: Int?
    var wrapperAdsCount: Int?
    
    var manifestDownloadTime: Double?
    var analyticsVersion: String?
    var adModule: String?
    var adModuleVersion: String?
    var playerStartuptime: Int?
    var autoplay: Bool?
    var time: Double?
    var adImpressionId: String?
    
    init(){
    }
    
    init(eventData: EventData, adBreak: AdBreak, adSample: AdSample){
        setEventData(eventData: eventData);
        setAdBreak(adBreak: adBreak)
        setAdSample(adSample: adSample)
    }
    
    
    public func setEventData(eventData: EventData){
        self.audioCodec = eventData.audioCodec
        self.cdnProvider = eventData.cdnProvider
        self.customData1 = eventData.customData1
        self.customData2 = eventData.customData2
        self.customData3 = eventData.customData3
        self.customData4 = eventData.customData4
        self.customData5 = eventData.customData5
        self.customData6 = eventData.customData6
        self.customData7 = eventData.customData7
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
    
    public func setAdBreak(adBreak: AdBreak){
        self.adFallbackIndex = adBreak.fallbackIndex
        self.adIsPersistent = adBreak.persistent
        self.adIdPlayer = adBreak.id
        self.adPosition = adBreak.position!.rawValue
        self.adOffset = adBreak.offset
        self.adPreloadOffset = adBreak.preloadOffset
        self.adReplaceContentDuration = adBreak.replaceContentDuration
        self.adScheduleTime = adBreak.scheduleTime
        (self.adTagServer, self.adTagPath) = Util.getHostNameAndPath(uriString: adBreak.tagUrl)
        self.adTagType = adBreak.tagType!.rawValue
        self.adTagUrl = adBreak.tagUrl
    }
    
    public func setAdSample(adSample: AdSample){
        self.adPodPosition = adSample.adPodPosition
        self.adStartupTime = adSample.adStartupTime
        self.clicked = adSample.clicked
        self.clickPercentage = adSample.clickPercentage
        self.clickPosition = adSample.clickPosition
        self.closed = adSample.closed
        self.closePercentage = adSample.closePercentage
        self.closePosition = adSample.closePosition
        self.completed = adSample.completed
        self.errorCode = adSample.errorCode
        self.errorData  = adSample.errorData
        self.errorMessage = adSample.errorMessage
        self.errorPercentage = adSample.errorPercentage
        self.errorPosition = adSample.errorPosition
        self.exitPosition = adSample.exitPosition
        self.midpoint = adSample.midpoint
        self.playPercentage = adSample.playPercentage
        self.quartile1 = adSample.quartile1
        self.quartile3 = adSample.quartile3
        self.skipped = adSample.skipped
        self.skipPercentage = adSample.skipPercentage
        self.skipPosition = adSample.skipPosition
        self.started = adSample.started
        self.timeFromContent = adSample.timeFromContent
        self.timePlayed = adSample.timePlayed
        self.timeToContent = adSample.timeToContent
    }
    
    private func setAd(ad: Ad){
        self.adClickThroughUrl = ad.clickThroughUrl
        self.adDescription = ad.description
        self.adDuration = ad.duration
        self.adId = ad.id
        self.adPlaybackHeight = ad.height
        self.adPlaybackWidth = ad.width
        self.adSkippable = ad.skippable
        self.adSkippableAfter = ad.skippableAfter
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
        self.minSuggestedDuration = ad.minSuggestedDuration
        self.streamFormat = ad.mimeType
        self.surveyUrl = ad.surveyUrl
        self.universalAdIdRegistry = ad.universalAdIdRegistry
        self.universalAdIdValue = ad.universalAdIdValue
        self.videoBitrate = ad.bitrate
        self.wrapperAdsCount = ad.wrapperAdsCount
    }
    
    public func jsonString() -> String {
           let encoder = JSONEncoder()
           if #available(iOS 11.0, tvOS 11.0, *) {
               encoder.outputFormatting = [.sortedKeys]
           }

           encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
           do {
               let jsonData = try encoder.encode(self)
               guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                   return ""
               }

               return jsonString
           } catch {
               return ""
           }
       }
}
