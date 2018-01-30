//
//  SimpleEventDataDispatcher.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/17/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

class SimpleEventDataDispatcher: EventDataDispatcher {
    private var httpClient: HttpClient
    private var enabled: Bool = false
    private var events = [EventData]();
    private var config: BitmovinAnalyticsConfig
    init(config: BitmovinAnalyticsConfig) {
        self.httpClient = HttpClient(urlString: BitmovinAnalyticsConfig.analyticsUrl)
        self.config = config
        makeLicenseCall()
    }
    
    func makeLicenseCall(){
        let licenseCall = LicenseCall(config: self.config)
        licenseCall.authenticate { (success) in
            if(success){
                self.enable()
            }else{
                self.disable()
            }
        }
    }
    
    func enable() {
        enabled = true
        for eventData:EventData in events {
            httpClient.post(json: eventData.jsonString(), completionHandler: { _, _, _ in
                
            })
        }
    }
    
    func disable() {
        enabled = false
    }
    
    func add(eventData: EventData) {
        if enabled {
            httpClient.post(json: eventData.jsonString(), completionHandler: { _, _, _ in
                
            });
        }else{
            events.append(eventData)
        }
        
    }
    func clear() {
        
    }
}
