import XCTest
@testable import BitmovinAnalyticsCollector

class EventDataFactoryTests: XCTestCase {
    
    func test_createEventData_should_returnEventDataWithBasicDataSet() {
        // arrange
        let userIdProvider = MockUserIdProvider()
        var getUserIdCnt = 0
        userIdProvider.setActionForGetUserId {
            getUserIdCnt += 1
            return "test-user-id"
        }
        let eventDataFactory = createDefaultEventDataFactoryForTest(userIdProvider: userIdProvider)
        
        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            nil,
            nil,
            nil,
            nil)
        
        // arrange
        XCTAssertNotNil(eventData.version)
        XCTAssertEqual(eventData.userId, "test-user-id")
        XCTAssertEqual(getUserIdCnt, 1)
        XCTAssertNotNil(eventData.userAgent)
        XCTAssertNotNil(eventData.domain)
        XCTAssertNotNil(eventData.language)
        
    }
    
    func test_createEventData_should_returnEventDataWithAnalyticsVersionSet() {
        // arrange
        let eventDataFactory = createDefaultEventDataFactoryForTest()
        
        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            nil,
            nil,
            nil,
            nil)
        
        // arrange
        XCTAssertNotNil(eventData.analyticsVersion)
    }
    
    func test_createEventData_should_returnEventDataWithConfigDataSet() {
        // arrange
        let config = getTestBitmovinConfig()
        let eventDataFactory = createDefaultEventDataFactoryForTest(config: config)
        
        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            nil,
            nil,
            nil,
            nil)
        
        // arrange
        XCTAssertEqual(eventData.key, config.key)
        XCTAssertEqual(eventData.playerKey, config.playerKey)
        XCTAssertNotNil(eventData.customUserId, config.customerUserId!)
        
        XCTAssertEqual(eventData.cdnProvider, config.cdnProvider)
        XCTAssertEqual(eventData.customData1, config.customData1)
        XCTAssertEqual(eventData.customData2, config.customData2)
        XCTAssertEqual(eventData.customData3, config.customData3)
        XCTAssertEqual(eventData.customData4, config.customData4)
        XCTAssertEqual(eventData.customData5, config.customData5)
        XCTAssertEqual(eventData.customData6, config.customData6)
        XCTAssertEqual(eventData.customData7, config.customData7)
        XCTAssertEqual(eventData.customData8, config.customData8)
        XCTAssertEqual(eventData.customData9, config.customData9)
        XCTAssertEqual(eventData.customData10, config.customData10)
        XCTAssertEqual(eventData.customData11, config.customData11)
        XCTAssertEqual(eventData.customData12, config.customData12)
        XCTAssertEqual(eventData.customData13, config.customData13)
        XCTAssertEqual(eventData.customData14, config.customData14)
        XCTAssertEqual(eventData.customData15, config.customData15)
        XCTAssertEqual(eventData.customData16, config.customData16)
        XCTAssertEqual(eventData.customData17, config.customData17)
        XCTAssertEqual(eventData.customData18, config.customData18)
        XCTAssertEqual(eventData.customData19, config.customData19)
        XCTAssertEqual(eventData.customData20, config.customData20)
        XCTAssertEqual(eventData.customData21, config.customData21)
        XCTAssertEqual(eventData.customData22, config.customData22)
        XCTAssertEqual(eventData.customData23, config.customData23)
        XCTAssertEqual(eventData.customData24, config.customData24)
        XCTAssertEqual(eventData.customData25, config.customData25)
        XCTAssertEqual(eventData.videoId, config.videoId)
        XCTAssertEqual(eventData.videoTitle, config.title!)
        XCTAssertEqual(eventData.experimentName, config.experimentName)
        XCTAssertEqual(eventData.path, config.path)
    }
    
    func test_createEventData_should_returnEventDataWithSourceMetaDataSet() {
        // arrange
        let eventDataFactory = createDefaultEventDataFactoryForTest()
        let currentSourceMetadata = SourceMetadata(
            videoId: "test-video-id-sourceMetadata",
            title: "test-title-sourceMetadata",
            path: "test-path-sourceMetadata",
            cdnProvider: "test-custom_cdn_provider-sourceMetadata",
            customData1: "test-customData1-sourceMetadata",
            customData2: "test-customData2-sourceMetadata",
            customData3: "test-customData3-sourceMetadata",
            customData4: "test-customData4-sourceMetadata",
            customData5: "test-customData5-sourceMetadata",
            customData6: "test-customData6-sourceMetadata",
            customData7: "test-customData7-sourceMetadata",
            customData8: "test-customData8-sourceMetadata",
            customData9: "test-customData9-sourceMetadata",
            customData10: "test-customData10-sourceMetadata",
            customData11: "test-customData11-sourceMetadata",
            customData12: "test-customData12-sourceMetadata",
            customData13: "test-customData13-sourceMetadata",
            customData14: "test-customData14-sourceMetadata",
            customData15: "test-customData15-sourceMetadata",
            customData16: "test-customData16-sourceMetadata",
            customData17: "test-customData17-sourceMetadata",
            customData18: "test-customData18-sourceMetadata",
            customData19: "test-customData19-sourceMetadata",
            customData20: "test-customData20-sourceMetadata",
            customData21: "test-customData21-sourceMetadata",
            customData22: "test-customData22-sourceMetadata",
            customData23: "test-customData23-sourceMetadata",
            customData24: "test-customData24-sourceMetadata",
            customData25: "test-customData25-sourceMetadata",
            experimentName: "test-experiment-sourceMetadata")
        
        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            Util.timeIntervalToCMTime(_: 0),
            Util.timeIntervalToCMTime(_: 10),
            60,
            currentSourceMetadata)
        
        // arrange
        XCTAssertEqual(eventData.cdnProvider, currentSourceMetadata.cdnProvider)
        XCTAssertEqual(eventData.customData1, currentSourceMetadata.customData1)
        XCTAssertEqual(eventData.customData2, currentSourceMetadata.customData2)
        XCTAssertEqual(eventData.customData3, currentSourceMetadata.customData3)
        XCTAssertEqual(eventData.customData4, currentSourceMetadata.customData4)
        XCTAssertEqual(eventData.customData5, currentSourceMetadata.customData5)
        XCTAssertEqual(eventData.customData6, currentSourceMetadata.customData6)
        XCTAssertEqual(eventData.customData7, currentSourceMetadata.customData7)
        XCTAssertEqual(eventData.customData8, currentSourceMetadata.customData8)
        XCTAssertEqual(eventData.customData9, currentSourceMetadata.customData9)
        XCTAssertEqual(eventData.customData10, currentSourceMetadata.customData10)
        XCTAssertEqual(eventData.customData11, currentSourceMetadata.customData11)
        XCTAssertEqual(eventData.customData12, currentSourceMetadata.customData12)
        XCTAssertEqual(eventData.customData13, currentSourceMetadata.customData13)
        XCTAssertEqual(eventData.customData14, currentSourceMetadata.customData14)
        XCTAssertEqual(eventData.customData15, currentSourceMetadata.customData15)
        XCTAssertEqual(eventData.customData16, currentSourceMetadata.customData16)
        XCTAssertEqual(eventData.customData17, currentSourceMetadata.customData17)
        XCTAssertEqual(eventData.customData18, currentSourceMetadata.customData18)
        XCTAssertEqual(eventData.customData19, currentSourceMetadata.customData19)
        XCTAssertEqual(eventData.customData20, currentSourceMetadata.customData20)
        XCTAssertEqual(eventData.customData21, currentSourceMetadata.customData21)
        XCTAssertEqual(eventData.customData22, currentSourceMetadata.customData22)
        XCTAssertEqual(eventData.customData23, currentSourceMetadata.customData23)
        XCTAssertEqual(eventData.customData24, currentSourceMetadata.customData24)
        XCTAssertEqual(eventData.customData25, currentSourceMetadata.customData25)
        XCTAssertEqual(eventData.videoId, currentSourceMetadata.videoId)
        XCTAssertEqual(eventData.videoTitle, currentSourceMetadata.title!)
        XCTAssertEqual(eventData.experimentName, currentSourceMetadata.experimentName)
        XCTAssertEqual(eventData.path, currentSourceMetadata.path)
    }

    func test_createEventData_should_returnEventDataWithParameterSet() {
        // arrange
        let eventDataFactory = createDefaultEventDataFactoryForTest()

        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            Util.timeIntervalToCMTime(_: 0),
            Util.timeIntervalToCMTime(_: 10),
            60,
            nil )

        // arrange
        XCTAssertEqual(eventData.state, "test-state")
        XCTAssertEqual(eventData.impressionId, "test-impression")
        XCTAssertEqual(eventData.videoTimeStart, 0)
        XCTAssertEqual(eventData.videoTimeEnd, 10000)
        XCTAssertEqual(eventData.drmLoadTime, 60)
    }
    
    private func createDefaultEventDataFactoryForTest(config: BitmovinAnalyticsConfig? = nil, userIdProvider: UserIdProvider? = nil) -> EventDataFactory {
        
        var c = config
        if c == nil {
            c = getTestBitmovinConfig()
        }
        
        var uip = userIdProvider
        if uip == nil {
            uip = RandomizedUserIdProvider()
        }
        
        return EventDataFactory(c!, uip!)
    }
    
    private func getTestBitmovinConfig() -> BitmovinAnalyticsConfig{
        let config = BitmovinAnalyticsConfig(key: "analytics-key", playerKey: "player-key")
        config.customerUserId = "test-customer-user-id"
        config.cdnProvider = "test-custom_cdn_provider"
        config.customData1 = "test-customData1"
        config.customData2 = "test-customData2"
        config.customData3 = "test-customData3"
        config.customData4 = "test-customData4"
        config.customData5 = "test-customData5"
        config.customData6 = "test-customData6"
        config.customData7 = "test-customData7"
        config.customData8 = "test-customData8"
        config.customData9 = "test-customData9"
        config.customData10 = "test-customData10"
        config.customData11 = "test-customData11"
        config.customData12 = "test-customData12"
        config.customData13 = "test-customData13"
        config.customData14 = "test-customData14"
        config.customData15 = "test-customData15"
        config.customData16 = "test-customData16"
        config.customData17 = "test-customData17"
        config.customData18 = "test-customData18"
        config.customData19 = "test-customData19"
        config.customData20 = "test-customData20"
        config.customData21 = "test-customData21"
        config.customData22 = "test-customData22"
        config.customData23 = "test-customData23"
        config.customData24 = "test-customData24"
        config.customData25 = "test-customData25"
        config.experimentName = "test-experiment"
        config.videoId = "test-video-id"
        config.title = "test-title"
        config.path = "test-path"
        return config
    }
}
