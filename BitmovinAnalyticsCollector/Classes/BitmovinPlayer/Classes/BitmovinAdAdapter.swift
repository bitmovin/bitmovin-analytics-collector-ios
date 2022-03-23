import BitmovinPlayer
import Foundation

public class BitmovinAdAdapter : NSObject, AdAdapter {
    private var bitmovinPlayer: Player
    private var adAnalytics: BitmovinAdAnalytics
    
    internal init(bitmovinPlayer: Player, adAnalytics: BitmovinAdAnalytics) {
        self.adAnalytics = adAnalytics;
        self.bitmovinPlayer = bitmovinPlayer;
        super.init()
        self.bitmovinPlayer.add(listener: self)
    }

    public func releaseAdapter() {
        self.bitmovinPlayer.remove(listener: self)
    }
    
    public func getModuleInformation() -> AdModuleInformation {
        let playerVersion = BitmovinPlayerUtil.playerVersion()
        return AdModuleInformation(name: "BMPDefaultAdvertisingService", version: playerVersion)
    }
    
    public func isAutoPlayEnabled() -> Bool {
        self.bitmovinPlayer.config.playbackConfiguration.isAutoplayEnabled
    }
}

extension BitmovinAdAdapter : PlayerListener {
    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
        self.adAnalytics.onAdManifestLoaded(adBreak: AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak), downloadTime: event.downloadTime)
    }
    
    public func onAdStarted(_ event: AdStartedEvent) {
        self.adAnalytics.onAdStarted(ad: AdModelMapper.fromPlayerAd(playerAd: event.ad))
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        self.adAnalytics.onAdFinished()
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        self.adAnalytics.onAdBreakStarted(adBreak: AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak))
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
        self.adAnalytics.onAdError(adBreak: AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adConfig), code: Int(event.code), message: event.message)
    }
    
    public func onAdQuartile(_ event: AdQuartileEvent) {
        self.adAnalytics.onAdQuartile(quartile: BitmovinPlayerUtil.getAdQuartileFromPlayerAdQuartile(adQuartile: event.adQuartile))
    }
}

