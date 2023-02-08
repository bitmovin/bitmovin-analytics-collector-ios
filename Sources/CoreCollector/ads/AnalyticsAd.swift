import Foundation

public class AnalyticsAd {
    public var isLinear: Bool = false
    public var width: Int = 0
    public var height: Int = 0
    public var id: String?
    public var mediaFileUrl: String?
    public var clickThroughUrl: String?
    public var bitrate: Int?
    public var minBitrate: Int?
    public var maxBitrate: Int?
    public var mimeType: String?
    public var adSystemName: String?
    public var adSystemVersion: String?
    public var advertiserName: String?
    public var advertiserId: String?
    public var apiFramework: String?
    public var creativeAdId: String?
    public var creativeId: String?
    public var universalAdIdRegistry: String?
    public var universalAdIdValue: String?
    public var description: String?
    public var minSuggestedDuration: TimeInterval?
    public var surveyUrl: String?
    public var surveyType: String?
    public var title: String?
    public var wrapperAdsCount: Int?
    public var codec: String?
    public var pricingValue: Int64?
    public var pricingModel: String?
    public var pricingCurrency: String?
    public var skippableAfter: TimeInterval?
    public var skippable: Bool?
    public var duration: TimeInterval?
    public var dealId: String?
    
    public init(){}
}
