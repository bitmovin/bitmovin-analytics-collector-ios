//
//  Ad.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class Ad {
    var isLinear: Bool = false
    var width: Int = 0
    var height: Int = 0
    var id: String?
    var mediaFileUrl: String?
    var clickThroughUrl: String?
    var bitrate: Int?
    var minBitrate: Int?
    var maxBitrate: Int?
    var mimeType: String?
    var adSystemName: String?
    var adSystemVersion: String?
    var advertiserName: String?
    var advertiserId: String?
    var apiFramework: String?
    var creativeAdId: String?
    var creativeId: String?
    var universalAdIdRegistry: String?
    var universalAdIdValue: String?
    var description: String?
    var minSuggestedDuration: Double?
    var surveyUrl: String?
    var surveyType: String?
    var title: String?
    var wrapperAdsCount: Int?
    var codec: String?
    var pricingValue: Double?
    var pricingModel: String?
    var pricingCurrency: String?
    var skippableAfter: Double?
    var skippable: Bool?
    var duration: Double?
    var dealId: String?
}
