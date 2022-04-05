import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import CoreCollector
#endif

class DeviceInformationDtoTests: XCTestCase {

    func testSerializesCorrectly() throws {
        // Arrange
        let deviceInfo = DeviceInformationDto(manufacturer: "Apple", model: "iPhone 12 Pro", isTV: false, operatingSystem: "iOS", operatingSystemMajorVersion: "15", operatingSystemMinorVersion: "2", deviceClass: DeviceClass.Phone)
        let expectedJSON = """
            {"operatingSystemMajor":"15","manufacturer":"Apple","deviceClass":"Phone","model":"iPhone 12 Pro","operatingSystem":"iOS","operatingSystemMinor":"2","isTV":false}
            """

        // Act
        let encoder = JSONEncoder()
        let json = try encoder.encode(deviceInfo)
        let jsonString = String(data: json, encoding: .utf8)!

        // Assert
        XCTAssertEqual(jsonString, expectedJSON)
    }
}
