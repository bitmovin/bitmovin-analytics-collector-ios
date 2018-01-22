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
    private var enabled: Bool = true
    init(config: BitmovinAnalyticsConfig) {
        self.httpClient = HttpClient(config: config)
    }
    
    func enable() {
        enabled = true
    }
    
    func disable() {
        enabled = false
    }
    
    func add(eventData: EventData) {
        if enabled {
            httpClient.post(json: eventData.jsonString())
        }
    }
    
    func clear() {
        
    }
}
