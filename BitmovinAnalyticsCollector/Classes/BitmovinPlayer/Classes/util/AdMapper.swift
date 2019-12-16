//
//  AdMapper.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Thomas Sabe on 16.12.19.
//

import Foundation
import BitmovinPlayer
public class AdMapper{
    
    func fromPlayerAd(playerAd: Ad) -> AnalyticsAd{
        return fromPlayerAd(collectorAd: AnalyticsAd(), playerAd: playerAd);
    }
    
    func fromPlayerAd(collectorAd: AnalyticsAd, playerAd: Ad) -> AnalyticsAd{
        collectorAd.isLinear = playerAd.isLinear
        collectorAd.width = Int(playerAd.width)
        collectorAd.height = Int(playerAd.height)
        collectorAd.id = playerAd.identifier
        collectorAd.mediaFileUrl = playerAd.mediaFileUrl
        if case let data? = playerAd.data {
            collectorAd.minBitrate = data.minBitrate == nil ? nil : Int(data.minBitrate!.pointee)
            collectorAd.maxBitrate = data.minBitrate == nil ? nil : Int(data.maxBitrate!.pointee)
            collectorAd.mimeType = data.mimeType
            collectorAd.bitrate = data.minBitrate == nil ? nil : Int(data.bitrate!.pointee)
            
            if(playerAd.data is VastAdData){
                fromVastAdData(collectorAd: collectorAd, vastData: playerAd.data as! VastAdData)
            }

            if(playerAd.data is ImaAdData){
                collectorAd.dealId = (playerAd.data as! ImaAdData).dealId
            }
        }
        
       
        if(playerAd is LinearAd){
            fromLinearAd(collectorAd: collectorAd, linearAd: playerAd as! LinearAd)
        }
        return collectorAd
    }
    
    func fromVastAdData(collectorAd:AnalyticsAd, vastData: VastAdData){
        collectorAd.title = vastData.adTitle
        collectorAd.adSystemName = vastData.adSystem?.name
        collectorAd.adSystemVersion = vastData.adSystem?.version
        collectorAd.wrapperAdsCount = vastData.wrapperAdIds.count
        collectorAd.description = vastData.adDescription
        collectorAd.advertiserId = vastData.advertiser?.identifier
        collectorAd.advertiserName = vastData.advertiser?.name
        collectorAd.apiFramework = vastData.apiFramework
        collectorAd.codec = vastData.codec
        
        if case let creative? = vastData.creative{
            collectorAd.creativeAdId = creative.adId
            collectorAd.creativeId = creative.identifier
            collectorAd.universalAdIdRegistry = creative.universalAdId?.idRegistry
            collectorAd.universalAdIdValue = creative.universalAdId?.value
        }
        
        if case let duration? = vastData.minSuggestedDuration{
            collectorAd.minSuggestedDuration = duration.int64Value * 1000
        }
        
        if case let pricing? = vastData.pricing{
            collectorAd.pricingCurrency = pricing.currency
            collectorAd.pricingModel = pricing.model
            collectorAd.pricingValue = pricing.value?.int64Value
        }
        
        if case let survey? = vastData.survey{
            collectorAd.surveyType = survey.type
            collectorAd.surveyUrl = survey.uri
        }
    }
    
    func fromLinearAd(collectorAd: AnalyticsAd, linearAd:LinearAd){
        collectorAd.duration = linearAd.duration?.int64Value;
        collectorAd.skippable = linearAd.skippable;
        collectorAd.skippableAfter = linearAd.skippableAfter?.int64Value;
    }
}
