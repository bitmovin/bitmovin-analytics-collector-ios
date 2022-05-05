//
//  BitrateLogProviderMock.swift
//  BitmovinAnalyticsCollector-iOS-Unit-AVPlayer-AVPlayerV2Tests
//
//  Created by Thomas Sabe on 05.05.22.
//

import Foundation
@testable import BitmovinAnalyticsCollector

class BitrateLogProviderMock: BitrateLogProvider {
    var events: [BitrateLogDto]? = nil
    
    func getEvents() -> [BitrateLogDto]? {
        return events
    }
}

