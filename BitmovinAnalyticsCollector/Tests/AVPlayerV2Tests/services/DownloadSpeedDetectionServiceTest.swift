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

    func test_detectDownloadSpeed_should_notAddMeasurement_when_accessLogProviderIsNil() {
        //arrange
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_notAddMeasurement_when_accessLogProviderReturnsNil() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_notAddMeasurement_when_generatedSpeedMeasurementIsNotValid() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransferred = -1
        log.numberOfMediaRequests = -1
        
        var log2 = AccessLogDto()
        log2.numberofBytesTransferred = 0
        log2.numberOfMediaRequests = 1
        mockAccessLogProvider.events = [log, log2]
        
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_notAddMeasurement_when_invalidPartialSpeedMeasurementWasTracked() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransferred = 10
        log.numberOfMediaRequests = 10
        
        mockAccessLogProvider.events = [log]
        
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        downloadSpeedDetectionService.detectDownloadSpeed()
        downloadSpeedMeter.getInfoAndReset()
        
        var log2 = AccessLogDto()
        log2.numberofBytesTransferred = 2
        log2.numberOfMediaRequests = 1
        // this will set the previous log entry with the new log entry in conflict and produce negative values
        mockAccessLogProvider.events = [log2]
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 0)
    }
    
    func test_detectDownloadSpeed_should_addMeasurementToDownloadSpeedMeter() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransferred = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 1)
        let speedMeasurement = downloadSpeedMeter.measures[0]
        XCTAssertEqual(speedMeasurement.numberOfSegmentsDownloaded, 2)
        XCTAssertEqual(speedMeasurement.downloadTime, 1000)
        XCTAssertEqual(speedMeasurement.numberOfBytesTransferred, 100)
    }
    
    func test_detectDownloadSpeed_should_addMeasurementToDownloadSpeedMeter_when_prevLogsContainsLessItemsThanNewOne() {
        //arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransferred = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        downloadSpeedDetectionService.detectDownloadSpeed()
        downloadSpeedMeter.getInfoAndReset()
        
        // access log has changed in the meanwhile
        log.numberofBytesTransferred += 50
        log.numberOfMediaRequests += 1
        
        var log2 = AccessLogDto()
        log2.numberofBytesTransferred = 1000
        log2.numberOfMediaRequests = 5
        
        var log3 = AccessLogDto()
        log3.numberofBytesTransferred = 10000
        log3.numberOfMediaRequests = 10
        mockAccessLogProvider.events = [log, log2, log3]
        
        
        // act
        downloadSpeedDetectionService.detectDownloadSpeed()
        
        // assert
        XCTAssertEqual(downloadSpeedMeter.measures.count, 1)
        let speedMeasurement = downloadSpeedMeter.measures[0]
        XCTAssertEqual(speedMeasurement.numberOfSegmentsDownloaded, 16)
        XCTAssertEqual(speedMeasurement.downloadTime, 1000)
        XCTAssertEqual(speedMeasurement.numberOfBytesTransferred, 11050)
    }
    
    func test_startMonitoring_should_callDetectDownloadSpeed() {
        // arrange
        let mockAccessLogProvider = AccessLogProviderMock()
        var log = AccessLogDto()
        log.numberofBytesTransferred = 100
        log.numberOfMediaRequests = 2
        mockAccessLogProvider.events = [log]
        let downloadSpeedMeterExpectation = expectation(description: "should add Measurement")
        let mockDownloadSpeedMeter = MockDownloadSpeedMeter(downloadSpeedMeterExpectation)
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: mockDownloadSpeedMeter)
        
        // act
        downloadSpeedDetectionService.startMonitoring(accessLogProvider: mockAccessLogProvider)
        
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
