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
    @objc public var heartbeatInterval: Int = 59_000
    
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
