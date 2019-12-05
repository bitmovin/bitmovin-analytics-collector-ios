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
    private var isPlaying = false
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
    
    public func onAdManifestLoaded() {
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
        
        adSample.completed = 1
        completeAd(adSample:adSample, exitPosition: adSample.ad.duration)
    }
    
    public func onAdBreakStarted() {
        print("onAdBreakStarted")
        self.adPodPosition = 0
        self.adStartupTimestamp = Date().timeIntervalSince1970Millis
    }
    
    public func onAdBreakFinished() {
        print("onAdBreakFinished")
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
        
        adSample.skipped = 1
        adSample.skipPosition = self.currentTime
        adSample.skipPercentage = Util.calculatePercentage(numerator: adSample.clickPosition, denominator: adSample.ad.duration, clamp: true)
        
        completeAd(adSample: adSample, exitPosition: adSample.skipPosition)
    }
        
    public func onAdError(code: Int?, message: String?) {
        print("onAdError")
        let adSample = self.activeAdSample ?? AdSample()
        
        adSample.errorCode = code
        adSample.errorMessage = message
        adSample.errorPosition = self.currentTime
        adSample.errorPercentage = Util.calculatePercentage(numerator: adSample.clickPosition, denominator: adSample.ad.duration, clamp: true)
        
        completeAd(adSample: adSample, exitPosition: adSample.errorPosition ?? 0)
    }
    
    private func resetActiveAd(){
        self.activeAdSample = nil
        self.currentTime = nil
    }
    
    private func completeAd(adSample: AdSample, exitPosition: Int64? = 0){
        adSample.exitPosition = exitPosition
        adSample.timePlayed = exitPosition
        adSample.playPercentage = Util.calculatePercentage(numerator: adSample.timePlayed, denominator: adSample.ad.duration, clamp: true)
        
        // reset startupTimestamp for the next ad, in case there are multiple ads in one ad break
        self.adStartupTimestamp = Date().timeIntervalSince1970Millis
        self.isPlaying = false
        sendAnalyticsRequest(adSample: adSample)
        resetActiveAd()
    }
    
    private func sendAnalyticsRequest(adSample: AdSample? = nil){
        
        guard let adapter = self.analytics.adapter else {
            return
        }
        
        let adEventData = AdEventData()
        
        adEventData.setEventData(eventData: adapter.createEventData())
        if case let adSample? = adSample {
            adEventData.setAdSample(adSample: adSample)
        }
        
        let moduleInfo = self.analytics.adAdapter?.getModuleInformation()
        if(moduleInfo != nil){
            adEventData.adModule = moduleInfo?.name
            adEventData.adModuleVersion = moduleInfo?.version
        }
        
        adEventData.autoplay = analytics.adAdapter?.isAutoPlayEnabled()
        adEventData.playerStartuptime = 1
        adEventData.time = Date().timeIntervalSince1970Millis
        adEventData.adImpressionId = Util.getUUID()
        
        self.analytics.sendAdEventData(adEventData: adEventData)
    }
}
