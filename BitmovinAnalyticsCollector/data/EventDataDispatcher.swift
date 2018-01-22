//
//  EventDataDispatcher.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/17/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

protocol EventDataDispatcher {
    func add(eventData: EventData)
    func enable()
    func disable()
    func clear()
}
