import Foundation
import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class BitrateDetectionServiceTest: XCTestCase {
    
    func test_detectBitrateChange_should_doNothing_when_accessLogIsNil() {
        // arrange
        let bitrateDetector = BitrateDetectionService()
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_accessLogReturnNil() {
        // arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = nil
        
        let bitrateDetector = BitrateDetectionService()
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogIsEmpty() {
        // arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = []
        
        let bitrateDetector = BitrateDetectionService()
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogDoesNotContainLogWithDurationWatched() {
        // arrange
        var log = AccessLogDto()
        log.durationWatched = 0
        
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService()
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogDidNotChange() {
        // arrange
        var log = AccessLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 10
        
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService()
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        bitrateDetector.detectBitrateChange()
        XCTAssertEqual(bitrateDetector.videoBitrate, 10)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 10)
    }
    
    func test_detectBitrateChange_should_changeBitrateValue() {
        // arrange
        var log = AccessLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 20
        
        var log2 = AccessLogDto()
        log2.durationWatched = 2
        log2.indicatedBitrate = 30
        
        var log3 = AccessLogDto()
        log3.durationWatched = 0
        log3.indicatedBitrate = 40
        
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = [log, log2, log3]
        
        let bitrateDetector = BitrateDetectionService()
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        let videoBitrateChangeExpectation = expectation(description: "should change videoBitrate")
        let kvo = bitrateDetector.observe(\.videoBitrate, options: [.new, .old]) {_,_ in
            videoBitrateChangeExpectation.fulfill()
        }
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 30)
        wait(for: [videoBitrateChangeExpectation], timeout: 1)
        kvo.invalidate()
    }
    
    func test_startMonitoring_should_callDetectBitrateChangeAndChangeValue() {
        // arrange
        var log = AccessLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 20
        
        var log2 = AccessLogDto()
        log2.durationWatched = 2
        log2.indicatedBitrate = 30
        
        var log3 = AccessLogDto()
        log3.durationWatched = 0
        log3.indicatedBitrate = 40
        
        let mockAccessLogProvider = AccessLogProviderMock()
        mockAccessLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService()
        
        var videoBitrateChangeExpectation = expectation(description: "should change videoBitrate first time")
        let kvo = bitrateDetector.observe(\.videoBitrate, options: [.new, .old]) {_,_ in
            videoBitrateChangeExpectation.fulfill()
            mockAccessLogProvider.events = [log, log2, log3]
        }
        
        // act
        bitrateDetector.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // assert
        wait(for: [videoBitrateChangeExpectation], timeout: 1.1)
        XCTAssertEqual(bitrateDetector.videoBitrate, 20)
        
        videoBitrateChangeExpectation = expectation(description: "should change videoBitrate second time")
        wait(for: [videoBitrateChangeExpectation], timeout: 1.1)
        XCTAssertEqual(bitrateDetector.videoBitrate, 30)
        
        bitrateDetector.stopMonitoring()
        
        videoBitrateChangeExpectation = expectation(description: "should not change videoBitrate a third time")
        videoBitrateChangeExpectation.isInverted = true
        wait(for: [videoBitrateChangeExpectation], timeout: 2)
        kvo.invalidate()
    }
}


