import XCTest
@testable import BitmovinAnalyticsCollector

class EventDataFactoryTests: XCTestCase {
    
    func test_createEventData_should_returnEventDataWithBasicDataSet() {
        // arrange
        let config = BitmovinAnalyticsConfig(key: "analytics-key")
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
        // arrange
        XCTAssertNotNil(eventData.version)
        XCTAssertNotNil(eventData.userId)
        XCTAssertNotNil(eventData.userAgent)
        XCTAssertNotNil(eventData.domain)
        XCTAssertNotNil(eventData.language)
    }
    
    func test_createEventData_should_returnEventDataWithAnalyticsVersionSet() {
        // arrange
        let config = BitmovinAnalyticsConfig(key: "analytics-key")
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
        // arrange
        XCTAssertNotNil(eventData.analyticsVersion)
    }
    
    func test_createEventData_should_returnEventDataWithConfigDataSet() {
        // arrange
        let config = getTestBitmovinConfig()
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
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
        let config = getTestBitmovinConfig()
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
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
        let playerAdapter = FakePlayerAdapter()
        playerAdapter.currentSourceMetadata = currentSourceMetadata
        eventDataFactory.useAdapter(playerAdapter: playerAdapter)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
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
    
    func test_createEventData_should_returnEventDataWithStateMachineDataSet() {
        // arrange
        let config = getTestBitmovinConfig()
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
        // arrange
        XCTAssertEqual(eventData.state, PlayerState.ready.rawValue)
        XCTAssertNotNil(eventData.impressionId)
    }
    
    func test_createEventData_should_returnEventDataWithDrmDataSet() {
        // arrange
        let config = getTestBitmovinConfig()
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        let playerAdapter = FakePlayerAdapter()
        playerAdapter.drmDownloadTime =  400
        eventDataFactory.useAdapter(playerAdapter: playerAdapter)
        
        // act
        let eventData = eventDataFactory.createEventData()
        
        // arrange
        XCTAssertEqual(eventData.drmLoadTime, 400)
    }
    
    func test_createEventData_should_notSetDrmLoadTimeTwice() {
        // arrange
        let config = getTestBitmovinConfig()
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        let playerAdapter = FakePlayerAdapter()
        playerAdapter.drmDownloadTime =  400
        eventDataFactory.useAdapter(playerAdapter: playerAdapter)
        
        // act
        let eventData1 = eventDataFactory.createEventData()
        let eventData2 = eventDataFactory.createEventData()
        
        // arrange
        XCTAssertEqual(eventData1.drmLoadTime, 400)
        XCTAssertNil(eventData2.drmLoadTime)
    }
    
    // This tests that the EventDataFactory is setting correct videoTimeStart and videoTimeEnd during the exitPlaying event
    func test_createEventData_should_returnEventDataWithVideoTimeDataSet() {
        // arrange
        let config = getTestBitmovinConfig()
        
        let stateMachine = StateMachine(config: config)
        let eventDataFactory = EventDataFactory(stateMachine, config)
        var eventData: EventData? = nil
        let mockDelegate = MockStateMachineDelegate()
        mockDelegate.setActionForExitPlaying {
            // act
            eventData = eventDataFactory.createEventData()
        }
        
        stateMachine.delegate = mockDelegate
        
        
        stateMachine.transitionState(destinationState: .startup, time: Util.timeIntervalToCMTime(_: 0))
        stateMachine.transitionState(destinationState: .playing, time: Util.timeIntervalToCMTime(_: 10))
        stateMachine.transitionState(destinationState: .paused, time: Util.timeIntervalToCMTime(_: 60))

        // arrange
        XCTAssertNotNil(eventData)
        XCTAssertEqual(eventData!.state, PlayerState.playing.rawValue)
        XCTAssertEqual(eventData!.videoTimeStart, 10000)
        XCTAssertEqual(eventData!.videoTimeEnd, 60000)
    }
    
    func test_createEventData_should_returnEventDataWithVideoStartupFailedSet() {
        // arrange
        let config = getTestBitmovinConfig()
        
        let stateMachine = StateMachine(config: config)
        stateMachine.setVideoStartFailed(withReason: "TEST_ERROR")
        let eventDataFactory = EventDataFactory(stateMachine, config)
        
        // act
        let eventData = eventDataFactory.createEventData()

        // arrange
        XCTAssertTrue(eventData.videoStartFailed!)
        XCTAssertEqual(eventData.videoStartFailedReason, "TEST_ERROR")
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
