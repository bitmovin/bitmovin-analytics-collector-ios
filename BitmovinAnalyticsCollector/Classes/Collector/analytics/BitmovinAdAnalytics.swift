//
//  BitmovinAdAnalytics.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class BitmovinAdAnalytics : NSObject{
    
    private var analytics: BitmovinAnalyticsInternal
    
    internal init(analytics: BitmovinAnalyticsInternal) {
        self.analytics = analytics;
    }
}
