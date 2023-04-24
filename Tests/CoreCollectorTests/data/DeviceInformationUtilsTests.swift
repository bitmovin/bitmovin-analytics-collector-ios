import XCTest
@testable import CoreCollector

class DeviceInformationUtilsTests: XCTestCase {
    func testLanguage() throws {
        let language = DeviceInformationUtils.language()

        XCTAssertEqual(language, "en_US")
    }

    func testBuildUserAgent() throws {
        let userAgent = DeviceInformationUtils.buildUserAgent(
            product: "xctest",
            model: "iPhone",
            height: CGFloat(1_136),
            version: "15.0",
            carrier: "Unknown Carrier"
        )

        XCTAssertEqual(userAgent, "xctest / Apple; iPhone 1136 / iOS 15.0 / Unknown Carrier")
    }

    func testGetDeviceInformation() throws {
        let deviceInfo = DeviceInformationUtils.getDeviceInformation()

        XCTAssertEqual(deviceInfo.manufacturer, "Apple")
        XCTAssertEqual(deviceInfo.model, "iPhone")
        XCTAssertFalse(deviceInfo.isTV)
        XCTAssertEqual(deviceInfo.operatingSystem, "iOS")
        XCTAssertEqual(deviceInfo.deviceClass, DeviceClass.phone)
    }

    func testGetDeviceClass() throws {
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.tv), DeviceClass.television)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.phone), DeviceClass.phone)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.pad), DeviceClass.tablet)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.unspecified), DeviceClass.other)

        if #available(iOS 14.0, *) {
            XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.mac), DeviceClass.desktop)
        } else {
            // Fallback on earlier versions
        }
    }

    func testIsTV() throws {
        XCTAssertTrue(DeviceInformationUtils.isTV(.tv))
        XCTAssertFalse(DeviceInformationUtils.isTV(.phone))
        XCTAssertFalse(DeviceInformationUtils.isTV(.pad))
        XCTAssertFalse(DeviceInformationUtils.isTV(.unspecified))

        if #available(iOS 14.0, *) {
            XCTAssertFalse(DeviceInformationUtils.isTV(.mac))
        } else {
            // Fallback on earlier versions
        }
    }
}
