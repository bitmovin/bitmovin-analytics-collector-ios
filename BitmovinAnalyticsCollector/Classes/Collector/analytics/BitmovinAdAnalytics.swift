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
    
    private func sendAnalyticsRequest(){
        let adEventData = AdEventData()
        
        guard let adapter = self.analytics.adapter else {
            return
        }
        
        adEventData.setEventData(eventData: adapter.createEventData())
        
        self.analytics.sendAdEventData(adEventData: adEventData)
    }
}
