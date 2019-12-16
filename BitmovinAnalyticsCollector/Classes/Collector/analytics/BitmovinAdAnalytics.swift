//
//  BitmovinAdAnalytics.swift
//  BitmovinAnalyticsCollector-iOS
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class BitmovinAdAnalytics{
    
    private var analytics: BitmovinAnalyticsInternal
    
    private var adPodPosition = 0
    private var adStartupTimestamp: Int64? = nil
    private var beginPlayingTimestamp: Int64? = nil
    private var activeAdSample: AdSample? = nil
    private var activeAdBreak: AnalyticsAdBreak? = nil
    private var isPlaying = false
    private var adManifestDownloadTimes = [String: Int64]()
        
    private var _currentTime: Int64?
    private var currentTime: Int64? {
        get {
            if(self.isPlaying){
                if(_currentTime == nil || self.beginPlayingTimestamp == nil){
                    return nil
                } else {
                    return _currentTime! + Date().timeIntervalSince1970Millis - self.beginPlayingTimestamp!
                }
            }
            else {
                return _currentTime
            }
        }
        set {
            self._currentTime = newValue
        }
    }
    
    internal init(analytics: BitmovinAnalyticsInternal) {
        self.analytics = analytics;
    }
    
    public func onAdManifestLoaded(adBreak: AnalyticsAdBreak, downloadTime: Int64) {
        self.adManifestDownloadTimes[adBreak.id] = downloadTime;
        if(adBreak.tagType == AdTagType.VMAP){
            sendAnalyticsRequest(adBreak: adBreak);
        }
        print("OnAdManifestLoaded")
    }
    
    public func onAdStarted(){
        print("onAdStarted")
        
        let currentTimestamp = Date().timeIntervalSince1970Millis
        
        let adSample = AdSample()
        
        if case let adStartupTime? = self.adStartupTimestamp {
            adSample.adStartupTime = currentTimestamp - adStartupTime
        }
        
        adSample.started = 1
        adSample.timePlayed = 0
        adSample.timeInViewport = 0
        adSample.adPodPosition = self.adPodPosition

        self.activeAdSample = adSample
        
        self.beginPlayingTimestamp = currentTimestamp
        self.isPlaying = true
        self.currentTime = 0
        self.adPodPosition += 1
    }
    
    public func onAdFinished(){
        print("onAdFinished")
        guard let adSample = self.activeAdSample else {
            return
        }
        guard let adBreak = self.activeAdBreak else {
            return
        }
        
        adSample.completed = 1
        completeAd(adBreak: adBreak, adSample:adSample, exitPosition: adSample.ad.duration)
    }
    
    public func onAdBreakStarted(adBreak: AnalyticsAdBreak) {
        print("onAdBreakStarted")
        self.adPodPosition = 0
        self.activeAdBreak = adBreak
        self.adStartupTimestamp = Date().timeIntervalSince1970Millis
    }
    
    public func onAdBreakFinished() {
        print("onAdBreakFinished")
        self.activeAdBreak = nil
        resetActiveAd()
    }
    
    public func onAdClicked(clickThroughUrl: String?) {
        print("onAdClicked")
        guard let adSample = self.activeAdSample else {
            return
        }
        
        adSample.ad.clickThroughUrl = clickThroughUrl
        adSample.clicked = 1
        adSample.clickPosition = self.currentTime
        adSample.clickPercentage = Util.calculatePercentage(numerator: adSample.clickPosition, denominator: adSample.ad.duration, clamp: true)
    }
    
    public func onAdSkipped() {
        print("onAdSkipped")
        guard let adSample = self.activeAdSample else {
            return
        }
        guard let adBreak = self.activeAdBreak else {
            return
        }
        
        adSample.skipped = 1
        adSample.skipPosition = self.currentTime
        adSample.skipPercentage = Util.calculatePercentage(numerator: adSample.clickPosition, denominator: adSample.ad.duration, clamp: true)
        
        completeAd(adBreak: adBreak, adSample: adSample, exitPosition: adSample.skipPosition)
    }
        
    public func onAdError(adBreak: AnalyticsAdBreak, code: Int?, message: String?) {
        print("onAdError")
        let adSample = self.activeAdSample ?? AdSample()
        
        if(adSample.ad.id != nil && adBreak.ads.contains { $0.id == adSample.ad.id}){
            adSample.errorPosition = self.currentTime
            adSample.errorPercentage = Util.calculatePercentage(numerator: adSample.clickPosition, denominator: adSample.ad.duration, clamp: true)
        }
        
        adSample.errorCode = code
        adSample.errorMessage = message
        
        completeAd(adBreak: adBreak, adSample: adSample, exitPosition: adSample.errorPosition ?? 0)
    }
    
    public func onAdQuartile(quartile: AdQuartile){
        guard self.activeAdSample != nil else {
            return;
        }
        
        switch quartile {
            case AdQuartile.FIRST_QUARTILE:
                self.activeAdSample!.quartile1 = 1;

            case AdQuartile.MIDPOINT:
                self.activeAdSample!.midpoint = 1;

            case AdQuartile.THIRD_QUARTILE:
                self.activeAdSample!.quartile3 = 1;
        }
    }
    
    private func resetActiveAd(){
        self.activeAdSample = nil
        self.currentTime = nil
    }
    
    private func completeAd(adBreak: AnalyticsAdBreak, adSample: AdSample, exitPosition: Int64? = 0){
        adSample.exitPosition = exitPosition
        adSample.timePlayed = exitPosition
        adSample.playPercentage = Util.calculatePercentage(numerator: adSample.timePlayed, denominator: adSample.ad.duration, clamp: true)
        
        // reset startupTimestamp for the next ad, in case there are multiple ads in one ad break
        self.adStartupTimestamp = Date().timeIntervalSince1970Millis
        self.isPlaying = false
        sendAnalyticsRequest(adBreak: adBreak, adSample: adSample)
        resetActiveAd()
    }
    
    private func getAdManifestDownloadTime(adBreak: AnalyticsAdBreak?) -> Int64?{
        if(adBreak == nil || self.adManifestDownloadTimes[adBreak!.id] != nil){
            return nil;
        }
        return self.adManifestDownloadTimes[adBreak!.id];
    }
    
    private func sendAnalyticsRequest(adBreak: AnalyticsAdBreak, adSample: AdSample? = nil){
        
        guard let adapter = self.analytics.adapter else {
            return
        }
        
        let adEventData = AdEventData()
        
        adEventData.setEventData(eventData: adapter.createEventData())
        adEventData.setAdBreak(adBreak: adBreak);
        if case let adSample? = adSample {
            adEventData.setAdSample(adSample: adSample)
        }
        
        let moduleInfo = self.analytics.adAdapter?.getModuleInformation()
        if(moduleInfo != nil){
            adEventData.adModule = moduleInfo?.name
            adEventData.adModuleVersion = moduleInfo?.version
        }
        
        adEventData.manifestDownloadTime = getAdManifestDownloadTime(adBreak: adBreak);
        adEventData.autoplay = analytics.adAdapter?.isAutoPlayEnabled()
        adEventData.playerStartuptime = 1
        adEventData.time = Date().timeIntervalSince1970Millis
        adEventData.adImpressionId = Util.getUUID()
        
        self.analytics.sendAdEventData(adEventData: adEventData)
    }
}
