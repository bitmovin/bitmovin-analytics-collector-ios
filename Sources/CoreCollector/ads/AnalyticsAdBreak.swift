import Foundation

public class AnalyticsAdBreak {
    public var id: String
    public var ads: [AnalyticsAd]
    public var position: AdPosition?
    public var offset: String?
    public var scheduleTime: TimeInterval?
    public var replaceContentDuration: TimeInterval?
    public var preloadOffset: Int64?
    public var tagType: AnalyticsAdTagType?
    public var tagUrl: String?
    public var persistent: Bool?
    public var fallbackIndex: Int = 0

    public init(id: String, ads: [AnalyticsAd]) {
        self.id = id
        self.ads = ads
    }
}
