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
    private var events = [EventData]()
    private var config: BitmovinAnalyticsConfig
    init(config: BitmovinAnalyticsConfig) {
        httpClient = HttpClient(urlString: BitmovinAnalyticsConfig.analyticsUrl)
        self.config = config
    }

    func makeLicenseCall() {
        let licenseCall = LicenseCall(config: config)
        licenseCall.authenticate { [weak self] success in
            if success {
                self?.enabled = true
                guard let events = self?.events.enumerated() else {
                    return
                }
                for (i, eventData) in events {
                    self?.httpClient.post(json: eventData.jsonString(), completionHandler: nil)
                    self?.events.remove(at: i)
                }
            } else {
                self?.enabled = false
                NotificationCenter.default.post(name: .licenseFailed, object: self)
            }
        }
    }

    func enable() {
        makeLicenseCall()
    }

    func disable() {
        enabled = false
    }

    func add(eventData: EventData) {
        if enabled {
            httpClient.post(json: eventData.jsonString(), completionHandler: nil)
        } else {
            events.append(eventData)
        }
    }

    func clear() {
    }
}
