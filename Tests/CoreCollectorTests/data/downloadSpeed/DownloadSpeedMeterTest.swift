import Foundation
import XCTest

@testable import CoreCollector

class DownloadSpeedMeterTest: XCTestCase {
    func testAdd_should_addNewItem() throws {
        // arrange
        let dsm = DownloadSpeedMeter()
        let measurement = SpeedMeasurement()

        // act
        dsm.add(measurement: measurement)

        // assert
        XCTAssertEqual(dsm.measures.count, 1)
    }

    func testGetInfo_should_returnZeroValues_when_noMeasurements() throws {
        // arrange
        let dsm = DownloadSpeedMeter()

        // act
        let info = dsm.getInfoAndReset()

        // assert
        XCTAssertEqual(info.segmentsDownloadSize, 0)
        XCTAssertEqual(info.segmentsDownloadTime, 0)
        XCTAssertEqual(info.segmentsDownloadCount, 0)
    }

    func testGetInfo_should_returnCorrectValues() throws {
        // arrange
        let dsm = DownloadSpeedMeter()
        var measurement = SpeedMeasurement()
        measurement.numberOfBytesTransferred = 50
        measurement.downloadTime = 1_000
        measurement.numberOfSegmentsDownloaded = 1
        dsm.add(measurement: measurement)

        var measurement2 = SpeedMeasurement()
        measurement2.numberOfBytesTransferred = 100
        measurement2.downloadTime = 1_000
        measurement2.numberOfSegmentsDownloaded = 2
        dsm.add(measurement: measurement2)

        // act
        let info = dsm.getInfoAndReset()

        // assert
        XCTAssertEqual(info.segmentsDownloadSize, 150)
        XCTAssertEqual(info.segmentsDownloadTime, 2_000)
        XCTAssertEqual(info.segmentsDownloadCount, 3)
        XCTAssertEqual(dsm.measures.count, 0)
    }
}
