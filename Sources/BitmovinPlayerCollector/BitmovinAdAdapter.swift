import BitmovinPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

public class BitmovinAdAdapter: NSObject, AdAdapter {
    private var bitmovinPlayer: Player
    private var adAnalytics: BitmovinAdAnalytics

    internal init(bitmovinPlayer: Player, adAnalytics: BitmovinAdAnalytics) {
        self.adAnalytics = adAnalytics
        self.bitmovinPlayer = bitmovinPlayer
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
        self.bitmovinPlayer.config.playbackConfig.isAutoplayEnabled
    }
}

extension BitmovinAdAdapter: PlayerListener {
    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent, player: Player) {
        let adBreak = AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak)
        self.adAnalytics.onAdManifestLoaded(adBreak: adBreak, downloadTime: event.downloadTime)
    }

    public func onAdStarted(_ event: AdStartedEvent, player: Player) {
        self.adAnalytics.onAdStarted(ad: AdModelMapper.fromPlayerAd(playerAd: event.ad))
    }

    public func onAdFinished(_ event: AdFinishedEvent, player: Player) {
        self.adAnalytics.onAdFinished()
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent, player: Player) {
        let adBreak = AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adBreak)
        self.adAnalytics.onAdBreakStarted(adBreak: adBreak)
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent, player: Player) {
        self.adAnalytics.onAdBreakFinished()
    }

    public func onAdClicked(_ event: AdClickedEvent, player: Player) {
        self.adAnalytics.onAdClicked(clickThroughUrl: event.clickThroughUrl?.absoluteString)
    }

    public func onAdSkipped(_ event: AdSkippedEvent, player: Player) {
        self.adAnalytics.onAdSkipped()
    }

    public func onAdError(_ event: AdErrorEvent, player: Player) {
        let adBreak = AdModelMapper.fromPlayerAdConfiguration(adConfiguration: event.adConfig)
        self.adAnalytics.onAdError(adBreak: adBreak, code: Int(event.code), message: event.message)
    }

    public func onAdQuartile(_ event: AdQuartileEvent, player: Player) {
        let quartile = BitmovinPlayerUtil.getAdQuartileFromPlayerAdQuartile(adQuartile: event.adQuartile)
        self.adAnalytics.onAdQuartile(quartile: quartile)
    }
}