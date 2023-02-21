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
        let deviceInfo = DeviceInformationDto(
            manufacturer: "Apple",
            model: "iPhone 12 Pro",
            isTV: false,
            operatingSystem: "iOS",
            operatingSystemMajorVersion: "15",
            operatingSystemMinorVersion: "2",
            deviceClass: DeviceClass.phone,
            screenHeight: 123,
            screenWidth: 321
        )
        let expectedJSON = """
            {"operatingSystemMajor":"15","manufacturer":"Apple","deviceClass":"Phone","model":"iPhone 12 Pro","operatingSystem":"iOS","operatingSystemMinor":"2","isTV":false,"screenHeight":123,"screenWidth":321}
            """

        // Act
        let encoder = JSONEncoder()
        let json = try encoder.encode(deviceInfo)
        let jsonString = String(data: json, encoding: .utf8)

        // Assert
        XCTAssertNotNil(jsonString)
        XCTAssertEqual(jsonString, expectedJSON)
    }
}
