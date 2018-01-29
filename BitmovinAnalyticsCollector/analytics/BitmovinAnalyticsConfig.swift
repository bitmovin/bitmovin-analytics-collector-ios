//
//  BitmovinAnalyticsConfig.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import UIKit

public class BitmovinAnalyticsConfig {
    
    static var analyticsUrl: String = "https://analytics-ingress-global.bitmovin.com/analytics";
    public var cdnProvider: CdnProver?
    public var customData1: String?
    public var customData2: String?
    public var customData3: String?
    public var customData4: String?
    public var customData5: String?
    public var customerUserId: String?
    public var experimentName: String?
    public var videoId: String?
    public var key: String
    public var playerKey: String = ""
    public var path: String?
    
    var heartbeatInterval: Int = 59000

    public init(key: String, playerKey: String){
        self.key = key;
        self.playerKey = playerKey;
    }
    
    public init(key: String){
        self.key = key;
    }
}
