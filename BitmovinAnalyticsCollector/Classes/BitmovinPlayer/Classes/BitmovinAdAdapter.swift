//
//  BitmovinAdAdapter.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import BitmovinPlayer
import Foundation
public class BitmovinAdAdapter: NSObject, AdAdapter{
    
    private var bitmovinPlayer: BitmovinPlayer
    private var adAnalytics: BitmovinAdAnalytics
    
    internal init(bitmovinPlayer: BitmovinPlayer, adAnalytics: BitmovinAdAnalytics){
        self.adAnalytics = adAnalytics;
        self.bitmovinPlayer = bitmovinPlayer;
        super.init()
        self.bitmovinPlayer.add(listener: self)
    }

    func releaseAdapter() {
        self.bitmovinPlayer.remove(listener: self)
    }
}

extension BitmovinAdAdapter : PlayerListener {
    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
        print("OnAdManifestLoaded")
    }
    
    public func onAdStarted(_ event: AdStartedEvent) {
        print("onAdStarted")
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        print("onAdFinished")
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        print("onAdBreakStarted")
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        print("onAdBreakFinished")
    }
    
    public func onAdClicked(_ event: AdClickedEvent) {
        print("onAdClicked")
    }
    
    public func onAdSkipped(_ event: AdSkippedEvent) {
        print("onAdSkipped")
    }
    
    public func onAdScheduled(_ event: AdScheduledEvent) {
        print("onAdScheduled")
    }
    
    public func onAdError(_ event: AdErrorEvent) {
        print("onAdError")
    }
}

