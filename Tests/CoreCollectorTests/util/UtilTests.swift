import AVKit
import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import CoreCollector
import CoreMedia
#endif

class UtilTests: XCTestCase {
    func test_timeIntervalToCMTime() throws {
        // Arrange
        let tests: [(name: String, timeInterval: TimeInterval, expectedTime: CMTime?)] = [
            ("TimeIntervalIsNaN", TimeInterval.nan, nil),
            ("TimeIntervalIsInfinite", TimeInterval.infinity, nil),
            ("WithValidTimeInterval", TimeInterval(100), CMTimeMakeWithSeconds(100, preferredTimescale: 1_000))
        ]

        for test in tests {
            // Act
            let actualTime = Util.timeIntervalToCMTime(test.timeInterval)

            // Assert
            XCTAssertEqual(test.expectedTime, actualTime, "\(String(describing: test.name)): expected time to be \(String(describing: test.expectedTime)), but got \(String(describing: actualTime))")
        }
    }

    func test_streamType() throws {
        // Arrange
        let tests: [(streamURL: String, expectedStreamType: StreamType?)] = [
            ("https://my-domain.com/assets/manifest.m3u8", StreamType.hls),
            ("https://my-domain.com/assets/manifest.mp4", StreamType.progressive),
            ("https://my-domain.com/assets/manifest.m4v", StreamType.progressive),
            ("https://my-domain.com/assets/manifest.m4a", StreamType.progressive),
            ("https://my-domain.com/assets/manifest.webm", StreamType.progressive),
            ("https://my-domain.com/assets/manifest.mpd", StreamType.dash),
            ("https://my-domain.com/assets/manifest.unknown", nil)
        ]

        for test in tests {
            // Act
            let actualStreamType = Util.streamType(from: test.streamURL)

            // Assert
            XCTAssertEqual(test.expectedStreamType, actualStreamType, "expected streamType to be \(String(describing: test.expectedStreamType)), but got \(String(describing: actualStreamType))")
        }
    }

    func test_getHostNameAndPath() throws {
        // Arrange
        let tests: [(name: String, uriString: String, expectedHost: String?, expectedPath: String?)] = [
            ("SuccessfullyExtractHostAndPathWithoutQueryParams", "https://my-domain.com/assets/manifest.m3u8", "my-domain.com", "/assets/manifest.m3u8"),
            ("SuccessfullyExtractHostAndPathWithQueryParams", "https://my-domain.com/manifest.m3u8?query=asdf", "my-domain.com", "/manifest.m3u8"),
            ("invalidURI", "notAnURI", nil, "notAnURI")
        ]

        for test in tests {
            // Act
            let (actualHost, actualPath) = Util.getHostNameAndPath(uriString: test.uriString)

            // Assert
            XCTAssertEqual(test.expectedHost, actualHost, "\(String(describing: test.name)): expected host to be \(String(describing: test.expectedHost)), but got \(String(describing: actualHost))")
            XCTAssertEqual(test.expectedPath, actualPath, "\(String(describing: test.name)): expected path to be \(String(describing: test.expectedPath)), but got \(String(describing: actualPath))")
        }
    }

    func test_calculatePercentage() throws {
        // Arrange
        let tests: [(name: String, numerator: Int64?, demoninator: Int64?, clamp: Bool, expectedPct: Int?)] = [
            ("WithNumeratorEqualNil", nil, Int64(2), false, nil),
            ("WithDenominatorEqualNil", Int64(10), nil, false, nil),
            ("WithDenominatorEqualZero", Int64(10), 0, false, nil),
            ("WithoutClampingTo100", Int64(10), Int64(2), false, Int(500)),
            ("WithClampingTo100", Int64(10), Int64(2), true, Int(100))
        ]

        for test in tests {
            // Act
            let actualPct = Util.calculatePercentage(
                numerator: test.numerator,
                denominator: test.demoninator,
                clamp: test.clamp
            )

            // Assert
            XCTAssertEqual(test.expectedPct, actualPct, "\(String(describing: test.name)): expected output to be \(String(describing: test.expectedPct)), but got \(String(describing: actualPct))")
        }
    }

    func test_calculatePercentageForTimeInterval() throws {
        // Arrange
        let tests: [(name: String, numerator: TimeInterval?, demoninator: TimeInterval?, clamp: Bool, expectedPct: Int?)] = [
            ("WithNumeratorEqualNil", nil, Double(2), false, nil),
            ("WithDenominatorEqualNil", Double(10), nil, false, nil),
            ("WithDenominatorEqualZero", Double(10), 0, false, nil),
            ("WithoutClampingTo100", Double(10), Double(2), false, Int(500)),
            ("WithClampingTo100", Double(10), Double(2), true, Int(100))
        ]

        for test in tests {
            // Act
            let actualPct = Util.calculatePercentageForTimeInterval(
                numerator: test.numerator,
                denominator: test.demoninator,
                clamp: test.clamp
            )

            // Assert
            XCTAssertEqual(test.expectedPct, actualPct, "\(String(describing: test.name)): expected output to be \(String(describing: test.expectedPct)), but got \(String(describing: actualPct))")
        }
    }
}
