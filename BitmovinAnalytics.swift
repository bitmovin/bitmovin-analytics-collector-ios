//
//  BitmovinAnalytics.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Roland on 28.02.19.
//

import Foundation
import Foundation
import BitmovinPlayer

public class BitmovinAnalytics : BitmovinPlayerCollector {
    
    public override init(config: BitmovinAnalyticsConfig) {
        super.init(config: config);
    }
    
    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    public func attachBitmovinPlayer(player: BitmovinPlayer) {
        super.attachPlayer(player: player)
    }
}
