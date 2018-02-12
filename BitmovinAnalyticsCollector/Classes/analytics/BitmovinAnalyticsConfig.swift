//
//  BitmovinAnalyticsConfig.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import UIKit

public class BitmovinAnalyticsConfig {
    static var analyticsUrl: String = "https://analytics-ingress-global.bitmovin.com/analytics"
    static var analyticsLicenseUrl: String = "https://analytics-ingress-global.bitmovin.com/licensing"

    /**
     * CDN Provide that the video playback session is using
     */
    public var cdnProvider: CdnProver?

    /**
     * Optional free-form custom data
     */
    public var customData1: String?

    /**
     * Optional free-form custom data
     */
    public var customData2: String?

    /**
     * Optional free-form custom data
     */
    public var customData3: String?

    /**
     * Optional free-form custom data
     */
    public var customData4: String?

    /**
     * Optional free-form custom data
     */
    public var customData5: String?

    /**
     * User ID of the customer
     */
    public var customerUserId: String?

    /**
     * Experiment name needed for A/B testing
     */
    public var experimentName: String?

    /**
     * ID of the video in the CMS system
     */
    public var videoId: String?

    /**
     * Analytics key. Find this value on dashboard.bitmovin.com/analytics
     */
    public var key: String

    /**
     * Player key. Find this value on dashboard.bitmovin.com/analytics
     */
    public var playerKey: String = ""

    /**
     * Breadcrumb path to show where in the app the user is
     */
    public var path: String?

    /**
     * How often the video engine should heartbeat
     */
    public var heartbeatInterval: Int = 59000

    public init(key: String, playerKey: String) {
        self.key = key
        self.playerKey = playerKey
    }

    public init(key: String) {
        self.key = key
    }
}
