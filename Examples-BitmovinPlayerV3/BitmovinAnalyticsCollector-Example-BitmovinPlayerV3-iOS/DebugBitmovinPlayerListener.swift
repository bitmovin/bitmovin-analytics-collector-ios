//
//  DebugPlayerListener.swift
//  BitmovinAnalyticsCollector_Example
//
//  Created by Thomas Sabe on 28.04.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinPlayer

class DebugBitmovinPlayerEvents: NSObject, PlayerListener, SourceListener {
    func onEvent(_ event: Event, player: Player) {
        print("onEvent PlayerListener: \(event.name)")
    }
    
    func onEvent(_ event: SourceEvent, source: Source) {
        print("onEvent SourceListener: \(event.name) for source: \(source.sourceConfig.url)")
    }
}
