//
//  BitmovinAdAnalytics.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class BitmovinAdAnalytics{
    
    private var analytics: BitmovinAnalyticsInternal
    
    internal init(analytics: BitmovinAnalyticsInternal) {
        self.analytics = analytics;
    }
    
    public func onAdManifestLoaded() {
        print("OnAdManifestLoaded")
    }
    
    public func onAdStarted(){
        print("onAdStarted")
        
    }
    
    public func onAdFinished(){
        print("onAdFinished")
        sendAnalyticsRequest()
    }
    
    
    public func onAdBreakStarted() {
        print("onAdBreakStarted")
    }
    
    public func onAdBreakFinished() {
        print("onAdBreakFinished")
    }
    
    public func onAdClicked() {
        print("onAdClicked")
    }
    
    public func onAdSkipped() {
        print("onAdSkipped")
    }
    
    public func onAdScheduled() {
        print("onAdScheduled")
    }
    
    public func onAdError() {
        print("onAdError")
    }
    
    private func sendAnalyticsRequest(){
        
        guard let adapter = self.analytics.adapter else {
            return
        }
        
        let adEventData = AdEventData()
        
        adEventData.setEventData(eventData: adapter.createEventData())
        
        let moduleInfo = self.analytics.adAdapter?.getModuleInformation()
        if(moduleInfo != nil){
            adEventData.adModule = moduleInfo?.name
            adEventData.adModuleVersion = moduleInfo?.version
        }
        
        adEventData.autoplay = analytics.adAdapter?.isAutoPlayEnabled()
        adEventData.playerStartuptime = 1
        adEventData.time = Date().timeIntervalSince1970Millis
        adEventData.adImpressionId = Util.getUUID()
        
        self.analytics.sendAdEventData(adEventData: adEventData)
    }
}
