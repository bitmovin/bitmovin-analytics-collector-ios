import Foundation

@objc
@objcMembers
public class BitmovinAnalyticsConfig: NSObject, CustomDataConfig{
    internal func getCustomData() -> CustomData {
        let customData = CustomData()
        customData.customData1 = self.customData1
        customData.customData2 = self.customData2
        customData.customData3 = self.customData3
        customData.customData4 = self.customData4
        customData.customData5 = self.customData5
        customData.customData6 = self.customData6
        customData.customData7 = self.customData7
        customData.customData8 = self.customData8
        customData.customData9 = self.customData9
        customData.customData10 = self.customData10
        customData.customData11 = self.customData11
        customData.customData12 = self.customData12
        customData.customData13 = self.customData13
        customData.customData14 = self.customData14
        customData.customData15 = self.customData15
        customData.customData16 = self.customData16
        customData.customData17 = self.customData17
        customData.customData18 = self.customData18
        customData.customData19 = self.customData19
        customData.customData20 = self.customData20
        customData.customData21 = self.customData21
        customData.customData22 = self.customData22
        customData.customData23 = self.customData23
        customData.customData24 = self.customData24
        customData.customData25 = self.customData25
        customData.customData26 = self.customData26
        customData.customData27 = self.customData27
        customData.customData28 = self.customData28
        customData.customData29 = self.customData29
        customData.customData30 = self.customData30
        customData.experimentName = self.experimentName
        return customData
    }
    
    internal func setCustomData(customData: CustomData) {
        self.customData1 = customData.customData1
        self.customData2 = customData.customData2
        self.customData3 = customData.customData3
        self.customData4 = customData.customData4
        self.customData5 = customData.customData5
        self.customData6 = customData.customData6
        self.customData7 = customData.customData7
        self.customData8 = customData.customData8
        self.customData9 = customData.customData9
        self.customData10 = customData.customData10
        self.customData11 = customData.customData11
        self.customData12 = customData.customData12
        self.customData13 = customData.customData13
        self.customData14 = customData.customData14
        self.customData15 = customData.customData15
        self.customData16 = customData.customData16
        self.customData17 = customData.customData17
        self.customData18 = customData.customData18
        self.customData19 = customData.customData19
        self.customData20 = customData.customData20
        self.customData21 = customData.customData21
        self.customData22 = customData.customData22
        self.customData23 = customData.customData23
        self.customData24 = customData.customData24
        self.customData25 = customData.customData25
        self.customData26 = customData.customData26
        self.customData27 = customData.customData27
        self.customData28 = customData.customData28
        self.customData29 = customData.customData29
        self.customData30 = customData.customData30
        self.experimentName = customData.experimentName
    }
    
    static var analyticsUrl: String = "https://analytics-ingress-global.bitmovin.com/analytics"
    static var adAnalyticsUrl: String = "https://analytics-ingress-global.bitmovin.com/analytics/a"
    static var analyticsLicenseUrl: String = "https://analytics-ingress-global.bitmovin.com/licensing"

    /**
     * CDN Provide that the video playback session is using
     */
    @objc public var cdnProvider: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData1: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData2: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData3: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData4: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData5: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData6: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData7: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData8: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData9: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData10: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData11: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData12: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData13: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData14: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData15: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData16: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData17: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData18: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData19: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData20: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData21: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData22: String?

    /**
     * Optional free-form custom data
     */
    @objc public var customData23: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData24: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData25: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData26: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData27: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData28: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData29: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public var customData30: String?
    
    /**
     * User ID of the customer
     */
    @objc public var customerUserId: String?

    /**
     * Experiment name needed for A/B testing
     */
    @objc public var experimentName: String?

    /**
     * ID of the video in the CMS system
     */
    @objc public var videoId: String?

    /**
     * Human readable title of the video asset currently playing
     */
    @objc public var title: String?

    /**
     * Analytics key. Find this value on dashboard.bitmovin.com/analytics
     */
    @objc public var key: String

    /**
     * Player key. Find this value on dashboard.bitmovin.com/analytics
     */
    @objc public var playerKey: String = ""

    /**
     * Breadcrumb path to show where in the app the user is
     */
    @objc public var path: String?

    /**
     * Flag to see if stream is live before stream metadata is available (default: false)
     */
    @objc public var isLive: Bool = false
    
    /**
     * Flag to enable Ad tracking
     */
    @objc public var ads: Bool = false
    
    /**
     * How often the video engine should heartbeat
     */
    @available(*, deprecated, message: "No longer possible to change default value of 59700ms")
    @objc public var heartbeatInterval: Int = 59700
    
    /**
     * Flag to use randomised userId not depending on device specific values
     */
    @objc public var randomizeUserId: Bool = false
    
    @objc public init(key: String, playerKey: String) {
        self.key = key
        self.playerKey = playerKey
    }

    @objc public init(key: String) {
        self.key = key
    }
}
