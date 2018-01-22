//
//  EventDataTest.swift
//  BitmovinAnalyticsCollectorTests
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import XCTest
import BitmovinAnalyticsCollector

class EventDataTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:"9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac",playerKey:"18ca6ad5-9768-4129-bdf6-17685e0d14d2")
        config.cdnProvider = .akamai
        config.customData1 = "customData1"
        config.customData1 = "customData2"
        config.customData1 = "customData3"
        config.customData1 = "customData4"
        config.customData1 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiement-1"
        config.videoId = "unitTestVideoId"
        config.path = "/vod/breadcrumb/"
        
        let eventData:EventData = EventData(config: config, impressionId:"1234");
        
        let encoder = JSONEncoder();
        if #available(iOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }
        
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
        do {
            let jsonData = try encoder.encode(eventData)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                XCTFail();
                return
            }
            print(jsonString)
            let val = "{\"ad\":0,\"buffered\":0,\"cdnProvider\":\"akamai\",\"customData1\":\"customData5\",\"domain\":\"Unknow\",\"impressionId\":\"1234\",\"key\":\"9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac\",\"language\":\"en_US\",\"path\":\"\\/vod\\/breadcrumb\\/\",\"paused\":0,\"played\":0,\"playerKey\":\"9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac\"}"
            XCTAssertEqual(jsonString, val)
        }
        catch {
            XCTFail();
        }
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
