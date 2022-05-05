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
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogIsNil() {
        // arrange
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = nil
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogIsEmpty() {
        // arrange
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = []
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogDoesNotContainLogWithDurationWatched() {
        // arrange
        let log = BitrateLogDto()
        log.durationWatched = 0
        
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 0)
    }
    
    func test_detectBitrateChange_should_doNothing_when_bitrateLogDidNotChange() {
        // arrange
        let log = BitrateLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 10
        
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        bitrateDetector.videoBitrate = 10
        
        // act
        bitrateDetector.detectBitrateChange()
        
        // assert
        XCTAssertEqual(bitrateDetector.videoBitrate, 10)
    }
    
    func test_detectBitrateChange_should_changeBitrateValue() {
        // arrange
        let log = BitrateLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 20
        
        let log2 = BitrateLogDto()
        log2.durationWatched = 2
        log2.indicatedBitrate = 30
        
        let log3 = BitrateLogDto()
        log3.durationWatched = 0
        log3.indicatedBitrate = 40
        
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = [log, log2, log3]
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        bitrateDetector.videoBitrate = 10
        
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
        let log = BitrateLogDto()
        log.durationWatched = 1
        log.indicatedBitrate = 20
        
        let log2 = BitrateLogDto()
        log2.durationWatched = 2
        log2.indicatedBitrate = 30
        
        let log3 = BitrateLogDto()
        log3.durationWatched = 0
        log3.indicatedBitrate = 40
        
        let mockBitrateLogProvider = BitrateLogProviderMock()
        mockBitrateLogProvider.events = [log]
        
        let bitrateDetector = BitrateDetectionService(bitrateLogProvider: mockBitrateLogProvider)
        bitrateDetector.videoBitrate = 10
        
        var videoBitrateChangeExpectation = expectation(description: "should change videoBitrate first time")
        let kvo = bitrateDetector.observe(\.videoBitrate, options: [.new, .old]) {_,_ in
            videoBitrateChangeExpectation.fulfill()
            mockBitrateLogProvider.events = [log, log2, log3]
        }
        
        // act
        bitrateDetector.startMonitoring()
        
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


