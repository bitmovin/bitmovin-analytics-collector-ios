import Foundation
import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class DownloadSpeedDetectionServiceTest: XCTestCase {

    func test_detectDownloadSpeed_should_notAddMeasurement_when_accessLogProviderReturnsNil() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(accessLogProvider: mockAccessLogProvider, downloadSpeedMeter: downloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_notAddMeasurement_when_generatedSpeedMeasurementIsNotValid() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransfered = -1
        log.numberOfMediaRequests = -1
        
        var log2 = AccessLogDto()
        log2.numberofBytesTransfered = 0
        log2.numberOfMediaRequests = 1
        mockAccessLogProvider.events = [log, log2]
        
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(accessLogProvider: mockAccessLogProvider, downloadSpeedMeter: downloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_addMeasurementToDownloadSpeedMeter() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransfered = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(accessLogProvider: mockAccessLogProvider, downloadSpeedMeter: downloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 1)
        let speedMeasurement = downloadSpeedMeter.measures[0]
        XCTAssertEqual(speedMeasurement.segmentCount, 2)
        XCTAssertEqual(speedMeasurement.duration, 1000)
        XCTAssertEqual(speedMeasurement.size, 100)
    }
    
    func test_detectDownloadSpeed_should_addMeasurementToDownloadSpeedMeter_when_prevLogsContainsLessItemsThanNewOne() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransfered = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(accessLogProvider: mockAccessLogProvider, downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.detectDownloadSpeed()
        downloadSpeedMeter.reset()
        
        // access log has changed in the meanwhile
        log.numberofBytesTransfered += 50
        log.numberOfMediaRequests += 1
        
        var log2 = AccessLogDto()
        log2.numberofBytesTransfered = 1000
        log2.numberOfMediaRequests = 5
        
        var log3 = AccessLogDto()
        log3.numberofBytesTransfered = 10000
        log3.numberOfMediaRequests = 10
        mockAccessLogProvider.events = [log, log2, log3]
        
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 1)
        let speedMeasurement = downloadSpeedMeter.measures[0]
        XCTAssertEqual(speedMeasurement.segmentCount, 16)
        XCTAssertEqual(speedMeasurement.duration, 1000)
        XCTAssertEqual(speedMeasurement.size, 11050)
    }
    
    func test_startMonitoring_should_callDetectDownloadSpeed() {
        // arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransfered = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeterExpectation = expectation(description: "should add Measurement")
        let mockDownloadSpeedMeter = MockDownloadSpeedMeter(downloadSpeedMeterExpectation)
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(accessLogProvider: mockAccessLogProvider, downloadSpeedMeter: mockDownloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.startMonitoring()
        
        // assert
        XCTAssertEqual(mockDownloadSpeedMeter.measures.count, 0)
        wait(for: [downloadSpeedMeterExpectation], timeout: 1.1)
        XCTAssertEqual(mockDownloadSpeedMeter.measures.count, 1)
    }
    
    class MockDownloadSpeedMeter: DownloadSpeedMeter {
        private let expectation: XCTestExpectation
        
        init(_ expectation: XCTestExpectation) {
            self.expectation = expectation
        }
        
        override func add(measurement: SpeedMeasurement) {
            super.add(measurement: measurement)
            expectation.fulfill()
        }
    }
}
