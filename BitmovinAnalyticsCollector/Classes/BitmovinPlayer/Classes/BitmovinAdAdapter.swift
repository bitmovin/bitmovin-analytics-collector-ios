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
    private let adBreakMapper: AdBreakMapper
    private let adMapper: AdMapper
    
    internal init(bitmovinPlayer: BitmovinPlayer, adAnalytics: BitmovinAdAnalytics){
        self.adAnalytics = adAnalytics;
        self.bitmovinPlayer = bitmovinPlayer;
        self.adBreakMapper = AdBreakMapper();
        self.adMapper = AdMapper();
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
        self.adAnalytics.onAdManifestLoaded(adBreak: adBreakMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak), downloadTime: Int64(event.manifestDownloadTime * 1000))
    }
    
    public func onAdStarted(_ event: AdStartedEvent) {
        if(event.ad == nil){
            return;
        }
        
        self.adAnalytics.onAdStarted(ad: adMapper.fromPlayerAd(playerAd: event.ad!))
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        self.adAnalytics.onAdFinished()
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        if(event.adBreak == nil){
            return;
        }
        
        self.adAnalytics.onAdBreakStarted(adBreak: adBreakMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak))
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        self.adAnalytics.onAdBreakFinished()
    }
    
    public func onAdClicked(_ event: AdClickedEvent) {
        self.adAnalytics.onAdClicked(clickThroughUrl: event.clickThroughUrl?.absoluteString)
    }
    
    public func onAdSkipped(_ event: AdSkippedEvent) {
        self.adAnalytics.onAdSkipped()
    }
        
    public func onAdError(_ event: AdErrorEvent) {
        self.adAnalytics.onAdError(adBreak: adBreakMapper.fromPlayerAdConfiguration(adConfiguration: event.adConfig), code: Int(event.code), message: event.message)
    }
    
    public func onAdQuartile(_ event: AdQuartileEvent) {
        self.adAnalytics.onAdQuartile(quartile: Util.getAdQuartileFromPlayerAdQuartile(adQuartile: event.adQuartile))
    }
}

