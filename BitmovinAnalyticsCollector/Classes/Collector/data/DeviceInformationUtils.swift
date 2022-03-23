#if os(iOS)
import CoreTelephony
#endif

import Foundation
import UIKit

public class DeviceInformationUtils {
    
    static func language() -> String {
        return Locale.current.identifier
    }

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

        let userAgent = String(format: "%@ / Apple; %@ %.f / iOS %@ / %@", product, model, height, version, carrier)

        return userAgent
    }
    
    static func getDeviceInformation() -> DeviceInformationDto {
        return DeviceInformationDto(manufacturer: "Apple",
                                    model: UIDevice.current.model,
                                    isTV: UIDevice.current.userInterfaceIdiom == .tv,
                                    operatingSystem: UIDevice.current.systemName,
                                    operatingSystemMajorVersion: String(ProcessInfo().operatingSystemVersion.majorVersion),
                                    operatingSystemMinorVersion: String(ProcessInfo().operatingSystemVersion.minorVersion),
                                    deviceClass: getDeviceClass()
        )
    }
    
    static func getDeviceClass() -> DeviceClass {
        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            return DeviceClass.TV
        case .phone:
            return DeviceClass.Phone
        case .pad:
            return DeviceClass.Tablet
        case .mac:
            return DeviceClass.Desktop
        default:
            return DeviceClass.Other
        }
    }
}
