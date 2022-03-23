import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import BitmovinCollectorCore
#endif

class DeviceInformationUtilsTests: XCTestCase {

    func testLanguage() throws {
        let language = DeviceInformationUtils.language()
        
        XCTAssertEqual(language, "en_US")
    }
    
    func testBuildUserAgent() throws {
        let userAgent = DeviceInformationUtils.buildUserAgent(product: "xctest", model: "iPhone", height: CGFloat(1136), version: "15.0", carrier: "Unknown Carrier")
        
        XCTAssertEqual(userAgent, "xctest / Apple; iPhone 1136 / iOS 15.0 / Unknown Carrier")
    }
    
    func testGetDeviceInformation() throws {
        let deviceInfo = DeviceInformationUtils.getDeviceInformation()
        
        XCTAssertEqual(deviceInfo.manufacturer, "Apple")
        XCTAssertEqual(deviceInfo.model, "iPhone")
        XCTAssertEqual(deviceInfo.isTV, false)
        XCTAssertEqual(deviceInfo.operatingSystem, "iOS")
        XCTAssertEqual(deviceInfo.operatingSystemMajor, "15")
        XCTAssertEqual(deviceInfo.operatingSystemMinor, "0")
        XCTAssertEqual(deviceInfo.deviceClass, DeviceClass.Phone)
    }
    
    func testGetDeviceClass() throws {
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.tv), DeviceClass.TV)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.phone), DeviceClass.Phone)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.pad), DeviceClass.Tablet)
        XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.unspecified), DeviceClass.Other)
        
        if #available(iOS 14.0, *) {
            XCTAssertEqual(DeviceInformationUtils.getDeviceClass(.mac), DeviceClass.Desktop)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func testIsTV() throws {
        XCTAssertEqual(DeviceInformationUtils.isTV(.tv), true)
        XCTAssertEqual(DeviceInformationUtils.isTV(.phone), false)
        XCTAssertEqual(DeviceInformationUtils.isTV(.pad), false)
        XCTAssertEqual(DeviceInformationUtils.isTV(.unspecified), false)

        if #available(iOS 14.0, *) {
            XCTAssertEqual(DeviceInformationUtils.isTV(.mac), false)
        } else {
            // Fallback on earlier versions
        }
    }
}
