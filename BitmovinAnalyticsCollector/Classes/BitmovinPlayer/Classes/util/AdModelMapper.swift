import Foundation
import BitmovinPlayer
public class AdModelMapper {
    
    // AdBreak Mapper
    static func fromPlayerAdConfiguration(adConfiguration: AdConfig?) -> AnalyticsAdBreak {
        let collectorAdBreak = AnalyticsAdBreak(id: "notset",  ads: Array<AnalyticsAd>() );
        if (adConfiguration != nil) {
            fromPlayerAdConfiguration(collectorAdBreak: collectorAdBreak, adConfiguration: adConfiguration!);
        }
        
        return collectorAdBreak;
    }
    
    static func fromPlayerAdConfiguration(collectorAdBreak: AnalyticsAdBreak, adConfiguration: AdConfig) {
        
        if (!adConfiguration.replaceContentDuration.isNaN) {
            collectorAdBreak.replaceContentDuration = Int64(adConfiguration.replaceContentDuration) * 1000
        }
        
        if (adConfiguration is AdBreak) {
            fromPlayerAdBreak(collectorAdBreak: collectorAdBreak, playerAdBreak:adConfiguration as! AdBreak);
        }
    }
    
    static func fromPlayerAdBreak(collectorAdBreak: AnalyticsAdBreak, playerAdBreak:AdBreak) {
        
        var ads = Array<AnalyticsAd>();
        for ad in playerAdBreak.ads {
            ads.append(fromPlayerAd(playerAd:ad));
        }
        
        collectorAdBreak.id = playerAdBreak.identifier;
        collectorAdBreak.ads = ads;
        
        if (!playerAdBreak.scheduleTime.isNaN) {
            collectorAdBreak.scheduleTime = Int64(playerAdBreak.scheduleTime) * 1000;
        }
        if (playerAdBreak is ImaAdBreak) {
            fromImaAdBreak(collectorAdBreak: collectorAdBreak, imaAdBreak:  playerAdBreak as! ImaAdBreak);
        }
    }
    
    static func fromImaAdBreak(collectorAdBreak: AnalyticsAdBreak, imaAdBreak: ImaAdBreak) {
        collectorAdBreak.position = BitmovinPlayerUtil.getAdPositionFromString(string: imaAdBreak.position);
//        collectorAdBreak.fallbackIndex = Int(truncating: imaAdBreak.currentFallbackIndex ?? 0);
        collectorAdBreak.tagType = BitmovinPlayerUtil.getAdTagTypeFromAdTag(adTag: imaAdBreak.tag);
        collectorAdBreak.tagUrl = imaAdBreak.tag.url.absoluteString;
    }
    
    // Ad Mapper Methods
    static func fromPlayerAd(playerAd: Ad) -> AnalyticsAd {
        return fromPlayerAd(collectorAd: AnalyticsAd(), playerAd: playerAd);
    }
    
    static func fromPlayerAd(collectorAd: AnalyticsAd, playerAd: Ad) -> AnalyticsAd {
        collectorAd.isLinear = playerAd.isLinear
        collectorAd.width = Int(playerAd.width)
        collectorAd.height = Int(playerAd.height)
        collectorAd.id = playerAd.identifier
        collectorAd.mediaFileUrl = playerAd.mediaFileUrl?.absoluteString
        if case let data? = playerAd.data {
            if (data.minBitrate != -1) {
                collectorAd.minBitrate = Int(data.minBitrate)
            }
            collectorAd.maxBitrate = data.minBitrate == -1 ? nil : Int(data.maxBitrate)
            collectorAd.mimeType = data.mimeType
            collectorAd.bitrate = data.minBitrate == -1 ? nil : Int(data.bitrate)
            
            if (playerAd.data is VastAdData) {
                fromVastAdData(collectorAd: collectorAd, vastData: playerAd.data as! VastAdData)
            }

            if (playerAd.data is ImaAdData) {
                collectorAd.dealId = (playerAd.data as! ImaAdData).dealId
            }
        }
        
       
        if (playerAd is LinearAd) {
            fromLinearAd(collectorAd: collectorAd, linearAd: playerAd as! LinearAd)
        }
        return collectorAd
    }
    
    static func fromVastAdData(collectorAd:AnalyticsAd, vastData: VastAdData) {
        collectorAd.title = vastData.adTitle
        collectorAd.adSystemName = vastData.adSystem?.name
        collectorAd.adSystemVersion = vastData.adSystem?.version
        collectorAd.wrapperAdsCount = vastData.wrapperAdIds.count
        collectorAd.description = vastData.adDescription
        collectorAd.advertiserId = vastData.advertiser?.identifier
        collectorAd.advertiserName = vastData.advertiser?.name
        collectorAd.apiFramework = vastData.apiFramework
        collectorAd.codec = vastData.codec
        
        if case let creative? = vastData.creative {
            collectorAd.creativeAdId = creative.adId
            collectorAd.creativeId = creative.identifier
            collectorAd.universalAdIdRegistry = creative.universalAdId?.idRegistry
            collectorAd.universalAdIdValue = creative.universalAdId?.value
        }
        
        if (!vastData.minSuggestedDuration.isNaN){
            collectorAd.minSuggestedDuration = Int64(vastData.minSuggestedDuration) * 1000
        }
        
        if case let pricing? = vastData.pricing {
            collectorAd.pricingCurrency = pricing.currency
            collectorAd.pricingModel = pricing.model
            collectorAd.pricingValue = Int64(pricing.value)
        }
        
        if case let survey? = vastData.survey {
            collectorAd.surveyType = survey.type
            collectorAd.surveyUrl = survey.uri.absoluteString
        }
    }
    
    static func fromLinearAd(collectorAd: AnalyticsAd, linearAd: LinearAd) {
        
        if (!linearAd.duration.isNaN){
            collectorAd.duration = Int64(linearAd.duration) * 1000;
        }
        
        if (!linearAd.skippableAfter.isNaN){
            collectorAd.skippableAfter = Int64(linearAd.skippableAfter) * 1000;
            collectorAd.skippable = collectorAd.skippableAfter! > Int64(0) ? true : false;
        }
    }
}
