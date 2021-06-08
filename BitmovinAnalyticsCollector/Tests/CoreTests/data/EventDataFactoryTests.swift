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
            nil,
            false,
            nil )
        
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
            nil,
            false,
            nil )
        
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
            nil,
            false,
            nil )
        
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
            experimentName: "test-experiment-sourceMetadata")
        
        // act
        let eventData = eventDataFactory.createEventData(
            "test-state",
            "test-impression",
            Util.timeIntervalToCMTime(_: 0),
            Util.timeIntervalToCMTime(_: 10),
            60,
            currentSourceMetadata,
            true,
            "TEST_ERROR" )
        
        // arrange
        XCTAssertEqual(eventData.cdnProvider, currentSourceMetadata.cdnProvider)
        XCTAssertEqual(eventData.customData1, currentSourceMetadata.customData1)
        XCTAssertEqual(eventData.customData2, currentSourceMetadata.customData2)
        XCTAssertEqual(eventData.customData3, currentSourceMetadata.customData3)
        XCTAssertEqual(eventData.customData4, currentSourceMetadata.customData4)
        XCTAssertEqual(eventData.customData5, currentSourceMetadata.customData5)
        XCTAssertEqual(eventData.customData6, currentSourceMetadata.customData6)
        XCTAssertEqual(eventData.customData7, currentSourceMetadata.customData7)
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
            nil,
            true,
            "TEST_ERROR" )

        // arrange
        XCTAssertTrue(eventData.videoStartFailed!)
        XCTAssertEqual(eventData.videoStartFailedReason, "TEST_ERROR")
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
        config.experimentName = "test-experiment"
        config.videoId = "test-video-id"
        config.title = "test-title"
        config.path = "test-path"
        return config
    }
}
