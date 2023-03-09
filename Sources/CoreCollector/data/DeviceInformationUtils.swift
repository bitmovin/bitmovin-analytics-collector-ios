#if os(iOS)
import CoreTelephony
#endif

import Foundation
import UIKit

public enum DeviceInformationUtils {
    static func language() -> String {
        Locale.current.identifier
    }

    /// Returns device specific user agent.
    static func userAgent() -> String {
        let model = UIDevice.current.model
        let product = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown Product"
        let scale = UIScreen.main.scale
        let height = UIScreen.main.bounds.size.height * scale
        let version = UIDevice.current.systemVersion
        #if os(iOS)
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? "Unknown Carrier"
        #elseif os(tvOS)
        let carrier = "Unknown Carrier tvOS"
        #else
        let carrier = "Unknown Carrier OSX"
        #endif

        return buildUserAgent(product: product, model: model, height: height, version: version, carrier: carrier)
    }

    static func getDeviceInformation() -> DeviceInformationDto {
        let scale = UIScreen.main.scale

        return DeviceInformationDto(
            manufacturer: "Apple",
            model: UIDevice.current.model,
            isTV: isTV(UIDevice.current.userInterfaceIdiom),
            operatingSystem: UIDevice.current.systemName,
            operatingSystemMajorVersion: String(ProcessInfo().operatingSystemVersion.majorVersion),
            operatingSystemMinorVersion: String(ProcessInfo().operatingSystemVersion.minorVersion),
            deviceClass: getDeviceClass(UIDevice.current.userInterfaceIdiom),
            screenHeight: Int(UIScreen.main.bounds.size.height * scale),
            screenWidth: Int(UIScreen.main.bounds.size.width * scale)
        )
    }

    // #region Internal Helper Function

    static func buildUserAgent(
        product: String,
        model: String,
        height: CGFloat,
        version: String,
        carrier: String
    ) -> String {
        String(format: "%@ / Apple; %@ %.f / iOS %@ / %@", product, model, height, version, carrier)
    }

    static func getDeviceClass(_ userInterfaceIdiom: UIUserInterfaceIdiom) -> DeviceClass {
        switch userInterfaceIdiom {
        case .tv:
            return DeviceClass.television
        case .phone:
            return DeviceClass.phone
        case .pad:
            return DeviceClass.tablet
        case .mac:
            return DeviceClass.desktop
        default:
            return DeviceClass.other
        }
    }

    static func isTV(_ userInterfaceIdiom: UIUserInterfaceIdiom) -> Bool {
        userInterfaceIdiom == .tv
    }

    // #endregion
}