//
//  AdEventData.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class AdEventData: Codable {
    var videoImpressionId: String?
    var userAgent: String?
    var language: String?
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
    var path : String?
    var player: String?
    var playerKey: String?
    var playerTech: String?
    var screenHeight: Int?
    var screenWidth:Int?
    var version : String?
    var userId : String?
    var videoId : String?
    var videoTitle : String?
    var videoWindowHeight:Int?
    var videoWindowWidth:Int?
    var platform : String?
    var audioCodec : String?
    var videoCodec: String?
    
    var adIdPlayer: String?
    var adPosition: String?
    var adOffset: String?
    var adScheduleTime: Double?
    var adReplaceContentDuration: Double?
    var adPreloadOffset: Double?
    var adTagType: String?
    var adTagUrl: String?
    var adTagServer: String?
    var adTagPath: String?
    var adIsPersistent: Bool?
    var adFallbackIndex: Double = 0
    
    init(){
    }
    
    
    public func setEventData(eventData: EventData){
        self.videoImpressionId = eventData.impressionId
        self.userAgent = eventData.userAgent
        self.language = eventData.language
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
        self.path = eventData.path
        self.player = eventData.player
        self.playerKey = eventData.playerKey
        self.playerTech = eventData.playerTech
        self.screenHeight = eventData.screenHeight
        self.screenWidth = eventData.screenWidth
        self.version = eventData.version
        self.userId = eventData.userId
        self.videoId = eventData.videoId
        self.videoTitle = eventData.videoTitle
        self.videoWindowHeight = eventData.videoWindowHeight
        self.videoWindowWidth = eventData.videoWindowWidth
        self.platform = eventData.platform
        self.audioCodec = eventData.audioCodec
        self.videoCodec = eventData.videoCodec
    }
    
    public func setAdBreak(adBreak: AdBreak){
        self.adPosition = adBreak.position!.rawValue
        self.adOffset = adBreak.offset
        self.adScheduleTime = adBreak.scheduleTime
        self.adReplaceContentDuration = adBreak.replaceContentDuration
        self.adPreloadOffset = adBreak.preloadOffset
        (self.adTagServer, self.adTagPath) = Util.getHostNameAndPath(uriString: adBreak.tagUrl)
        self.adTagType = adBreak.tagType!.rawValue
        self.adTagUrl = adBreak.tagUrl
        self.adIsPersistent = adBreak.persistent
        self.adIdPlayer = adBreak.id
        self.adFallbackIndex = adBreak.fallbackIndex
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
