import BitmovinPlayerCore
import CoreCollector

internal enum AdModelMapper {
    // AdBreak Mapper
    static func fromPlayerAdConfiguration(adConfiguration: AdConfig?) -> AnalyticsAdBreak {
        let collectorAdBreak = AnalyticsAdBreak(id: "notset", ads: [AnalyticsAd]() )
        if let adConfiguration = adConfiguration {
            fromPlayerAdConfiguration(collectorAdBreak: collectorAdBreak, adConfiguration: adConfiguration)
        }

        return collectorAdBreak
    }

    static func fromPlayerAdConfiguration(collectorAdBreak: AnalyticsAdBreak, adConfiguration: AdConfig) {
        if !adConfiguration.replaceContentDuration.isNaN {
            collectorAdBreak.replaceContentDuration = adConfiguration.replaceContentDuration
        }

        if adConfiguration is AdBreak {
            fromPlayerAdBreak(collectorAdBreak: collectorAdBreak, playerAdBreak: adConfiguration as! AdBreak)
        }
    }

    static func fromPlayerAdBreak(collectorAdBreak: AnalyticsAdBreak, playerAdBreak: AdBreak) {
        var ads = [AnalyticsAd]()
        for ad in playerAdBreak.ads {
            ads.append(fromPlayerAd(playerAd: ad))
        }

        collectorAdBreak.id = playerAdBreak.identifier
        collectorAdBreak.ads = ads

        if !playerAdBreak.scheduleTime.isNaN {
            collectorAdBreak.scheduleTime = playerAdBreak.scheduleTime
        }
        if playerAdBreak is ImaAdBreak {
            fromImaAdBreak(collectorAdBreak: collectorAdBreak, imaAdBreak: playerAdBreak as! ImaAdBreak)
        }
    }

    static func fromImaAdBreak(collectorAdBreak: AnalyticsAdBreak, imaAdBreak: ImaAdBreak) {
        collectorAdBreak.position = BitmovinPlayerUtil.getAdPositionFromString(string: imaAdBreak.position)
        // TODO this property will be removed in future, so we need to retrieve this value from the configuration
//        if let currentFallbackIndexVariable = class_getInstanceVariable(type(of: imaAdBreak), "_currentFallbackIndex") {
//            if let currentFallbackIndex = object_getIvar(imaAdBreak, currentFallbackIndexVariable) as? Int? {
//                collectorAdBreak.fallbackIndex = (currentFallbackIndex ?? -1) + 1;
//            }
//        }
        collectorAdBreak.tagType = BitmovinPlayerUtil.getAdTagTypeFromAdTag(adTag: imaAdBreak.tag)
        collectorAdBreak.tagUrl = imaAdBreak.tag.url.absoluteString
    }

    // Ad Mapper Methods
    static func fromPlayerAd(playerAd: Ad) -> AnalyticsAd {
        fromPlayerAd(collectorAd: AnalyticsAd(), playerAd: playerAd)
    }

    static func fromPlayerAd(collectorAd: AnalyticsAd, playerAd: Ad) -> AnalyticsAd {
        collectorAd.isLinear = playerAd.isLinear
        collectorAd.width = Int(playerAd.width)
        collectorAd.height = Int(playerAd.height)
        collectorAd.id = playerAd.identifier
        collectorAd.mediaFileUrl = playerAd.mediaFileUrl?.absoluteString
        if case let data? = playerAd.data {
            if data.minBitrate != -1 {
                collectorAd.minBitrate = Int(data.minBitrate)
            }
            if data.maxBitrate != -1 {
                collectorAd.maxBitrate = Int(data.maxBitrate)
            }
            if data.bitrate != -1 {
                collectorAd.bitrate = Int(data.bitrate)
            }

            collectorAd.mimeType = data.mimeType
            if playerAd.data is VastAdData {
                fromVastAdData(collectorAd: collectorAd, vastData: playerAd.data as! VastAdData)
            }

            if playerAd.data is ImaAdData {
                collectorAd.dealId = (playerAd.data as! ImaAdData).dealId
            }
        }

        if playerAd is LinearAd {
            fromLinearAd(collectorAd: collectorAd, linearAd: playerAd as! LinearAd)
        }
        return collectorAd
    }

    static func fromVastAdData(collectorAd: AnalyticsAd, vastData: VastAdData) {
        collectorAd.title = vastData.adTitle
        collectorAd.adSystemName = vastData.adSystem?.name
        collectorAd.adSystemVersion = vastData.adSystem?.version
        collectorAd.wrapperAdsCount = vastData.wrapperAdIds.count
        collectorAd.description = vastData.adDescription
        collectorAd.advertiserId = vastData.advertiser?.identifier
        collectorAd.advertiserName = vastData.advertiser?.name
        collectorAd.apiFramework = vastData.apiFramework
        collectorAd.codec = vastData.codec

        if let creative = vastData.creative {
            collectorAd.creativeAdId = creative.adId
            collectorAd.creativeId = creative.identifier
            collectorAd.universalAdIdRegistry = creative.universalAdId?.idRegistry
            collectorAd.universalAdIdValue = creative.universalAdId?.value
        }

        if !vastData.minSuggestedDuration.isNaN {
            collectorAd.minSuggestedDuration = vastData.minSuggestedDuration
        }

        if case let pricing? = vastData.pricing {
            collectorAd.pricingCurrency = pricing.currency
            collectorAd.pricingModel = pricing.model
            collectorAd.pricingValue = Int64(pricing.value)
        }

        if case let survey? = vastData.survey {
            collectorAd.surveyType = survey.type
            let surveyUri: Any = survey.uri as Any
            if surveyUri is String {
                collectorAd.surveyUrl = surveyUri as? String
            } else if surveyUri is URL {
                collectorAd.surveyUrl = (surveyUri as? URL)?.absoluteString
            }
        }
    }

    static func fromLinearAd(collectorAd: AnalyticsAd, linearAd: LinearAd) {
        if !linearAd.duration.isNaN {
            collectorAd.duration = linearAd.duration
        }

        if !linearAd.skippableAfter.isNaN {
            collectorAd.skippableAfter = linearAd.skippableAfter.isNaN ? nil : linearAd.skippableAfter
            collectorAd.skippable = !linearAd.skippableAfter.isNaN
        }
    }
}
