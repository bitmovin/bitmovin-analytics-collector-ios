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
    
    func getModuleInformation()-> AdModuleInformation{
        let playerVersion = Util.playerVersion() ?? ""
        return AdModuleInformation(name: "DefaultAdvertisingService", version: playerVersion)
    }
    
    func isAutoPlayEnabled() -> Bool{
        self.bitmovinPlayer.config.playbackConfiguration.isAutoplayEnabled
    }
}

extension BitmovinAdAdapter : PlayerListener {
    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
    }
    
    public func onAdStarted(_ event: AdStartedEvent) {
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        self.adAnalytics.onAdFinished()
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
    }
    
    public func onAdClicked(_ event: AdClickedEvent) {
    }
    
    public func onAdSkipped(_ event: AdSkippedEvent) {
    }
    
    public func onAdScheduled(_ event: AdScheduledEvent) {
    }
    
    public func onAdError(_ event: AdErrorEvent) {
    }
}

