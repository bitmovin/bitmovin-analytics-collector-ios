@objc
@objcMembers
public class SourceMetadata: NSObject, CustomDataConfig {
    @objc public init(videoId: String? = nil, title: String? = nil, path: String? = nil, isLive: Bool = false, cdnProvider: String? = nil, customData1: String? = nil, customData2: String? = nil, customData3: String? = nil, customData4: String? = nil, customData5: String? = nil, customData6: String? = nil, customData7: String? = nil, customData8: String? = nil, customData9: String? = nil, customData10: String? = nil, customData11: String? = nil, customData12: String? = nil, customData13: String? = nil, customData14: String? = nil, customData15: String? = nil, customData16: String? = nil, customData17: String? = nil, customData18: String? = nil, customData19: String? = nil, customData20: String? = nil, customData21: String? = nil, customData22: String? = nil, customData23: String? = nil, customData24: String? = nil, customData25: String? = nil, customData26: String? = nil, customData27: String? = nil, customData28: String? = nil, customData29: String? = nil, customData30: String? = nil, experimentName: String? = nil) {
        self.videoId = videoId
        self.title = title
        self.path = path
        self.isLive = isLive
        self.cdnProvider = cdnProvider
        self.customData1 = customData1
        self.customData2 = customData2
        self.customData3 = customData3
        self.customData4 = customData4
        self.customData5 = customData5
        self.customData6 = customData6
        self.customData7 = customData7
        self.customData8 = customData8
        self.customData9 = customData9
        self.customData10 = customData10
        self.customData11 = customData11
        self.customData12 = customData12
        self.customData13 = customData13
        self.customData14 = customData14
        self.customData15 = customData15
        self.customData16 = customData16
        self.customData17 = customData17
        self.customData18 = customData18
        self.customData19 = customData19
        self.customData20 = customData20
        self.customData21 = customData21
        self.customData22 = customData22
        self.customData23 = customData23
        self.customData24 = customData24
        self.customData25 = customData25
        self.customData26 = customData26
        self.customData27 = customData27
        self.customData28 = customData28
        self.customData29 = customData29
        self.customData30 = customData30
        self.experimentName = experimentName
    }
    
    /**
     * ID of the video in the CMS system
     */
    @objc public private(set) var videoId: String?

    /**
     * Human readable title of the video asset currently playing
     */
    @objc public private(set) var title: String?
    
    /**
     * Breadcrumb path to show where in the app the user is
     */
    @objc public private(set) var path: String?

    /**
     * Flag to see if stream is live before stream metadata is available
     */
    @objc public private(set) var isLive: Bool
    
    /**
     * CDN Provide that the video playback session is using
     */
    @objc public private(set) var cdnProvider: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData1: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData2: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData3: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData4: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData5: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData6: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData7: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData8: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData9: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData10: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData11: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData12: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData13: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData14: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData15: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData16: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData17: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData18: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData19: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData20: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData21: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData22: String?

    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData23: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData24: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData25: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData26: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData27: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData28: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData29: String?
    
    /**
     * Optional free-form custom data
     */
    @objc public private(set) var customData30: String?
    
    /**
     * Experiment name needed for A/B testing
     */
    @objc public private(set) var experimentName: String?
    
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
}
