//
//  PlayerAdapter.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

protocol PlayerAdapter {
    func createEventData() -> EventData
    func startMonitoring()
}
