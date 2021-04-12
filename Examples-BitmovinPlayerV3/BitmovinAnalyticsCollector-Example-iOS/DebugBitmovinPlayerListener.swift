//
//  DebugPlayerListener.swift
//  BitmovinAnalyticsCollector_Example
//
//  Created by Thomas Sabe on 28.04.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinPlayer

class DebugBitmovinPlayerEvents: NSObject, PlayerListener {
    func onPlay(_ event: PlayEvent) {
        print("onPlay")
    }
    
    func onPaused(_ event: PausedEvent) {
        print("onPause")
    }
    
    func onReady(_ event: ReadyEvent) {
        print("onReady")
    }
    
    func onPlaying(_ event: PlayingEvent) {
        print("onPlaying")
    }
    
    func onSeek(_ event: SeekEvent) {
        print("onSeek")
    }
    
    func onSeeked(_ event: SeekedEvent) {
        print("onSeeked")
    }
    
    func onStallStarted(_ event: StallStartedEvent) {
        print("onStallStarted")
    }
    
    func onStallEnded(_ event: StallEndedEvent) {
        print("onStallEnded")
    }
     
    func onError(_ event: ErrorEvent) {
        print("onError")
    }
}
