//
//  EventData.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

public class EventData : Codable {
    var domain: String
    var path: String?
    var language: String
    var userAgent: String?
    var screenWidth: Int?
    var screenHeight: Int?
    var isLive: Bool = false
    var isCasting: Bool = false
    var videoDuration: Int = 0
    var time: Double?
    var videoWindowWidth: Int = 0
    var videoWindowHeight: Int = 0
    var droppedFrames: Int = 0
    var played: Int = 0
    var buffered: Int = 0
    var paused: Int = 0
    var ad: Int = 0
    var seeked: Double?
    var videoPlaybackWidth: Int?
    var videoPlaybackHeight: Int?
    var videoBitrate: Double = 0
    var audioBitrate: Double = 0
    var videoTimeStart: Int = 0
    var videoTimeEnd: Int = 0
    var videoStartupTime: Int = 0
    var duration: Int = 0
    var startupTime: Int = 0
    var analyticsVersion: String = "0"
    var key: String?
    var playerKey: String?
    var player: String?
    var cdnProvider: String?
    var streamForamt: String?
    var videoId: String?
    var customUserId: String?
    var customData1: String?
    var customData2: String?
    var customData3: String?
    var customData4: String?
    var customData5: String?
    var experimentName: String?
    var userId: String?
    var impressionId: String
    var state: String?
    var m3u8Url: String?
    var playerStartupTime: Int = 0
    var pageLoadType: Int = 1
    var pageLoadTime: Int = 0
    var version: String?
    
    public init(config: BitmovinAnalyticsConfig, impressionId: String) {
        self.domain = Util.bundle()
        
        if let text = Bundle(identifier: "com.bitmovin.BitmovinAnalyticsCollector")?.infoDictionary?["CFBundleShortVersionString"]  as? String {
            self.analyticsVersion = text
        }
        
        self.version = UIDevice.current.systemVersion
        
        self.language = Util.language()
        self.userAgent = Util.userAgent()
        self.impressionId = impressionId
        self.key = config.key
        self.playerKey = config.playerKey
        self.cdnProvider = config.cdnProvider?.rawValue
        self.customUserId = config.customerUserId
        self.customData1 = config.customData1
        self.customData2 = config.customData2
        self.customData3 = config.customData3
        self.customData4 = config.customData4
        self.customData5 = config.customData5
        self.videoId = config.videoId
        self.experimentName = config.experimentName
        self.path = config.path
    }
    
    public func jsonString() -> String{
        
        let encoder = JSONEncoder();
        if #available(iOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }
        
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
        do {
            let jsonData = try encoder.encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            
            return jsonString
        }
        catch {
            return ""
        }
    }
    
    
    
    
    
}
