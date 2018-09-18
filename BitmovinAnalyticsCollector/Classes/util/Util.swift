#if os(iOS)
import CoreTelephony
#endif

import Foundation
import AVKit

class Util {
    static func mainBundleIdentifier() -> String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return "Unknown"
        }
        return bundleIdentifier
    }

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

    static func version() -> String? {
        return Bundle(for: self).infoDictionary?["CFBundleShortVersionString"] as? String
    }

    static func doubleToCMTime(double: Double) -> CMTime? {
        return CMTimeMake(Int64(double), 1)
    }

    static func toJson<T: Codable>(object: T?) -> String {
        let encoder = JSONEncoder()
        if #available(iOS 11.0, tvOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }

        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
        do {
            let jsonData = try encoder.encode(object)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }

            return jsonString
        } catch {
            return ""
        }
    }
    
    static func getUserId() -> String {
        let defaults = UserDefaults.standard
        let userIdFromStore = defaults.string(forKey: "bitmovin_analytics_user_id")
        if (userIdFromStore != nil) {
            return userIdFromStore!;
        }
        
        let newUserId = NSUUID().uuidString
        defaults.set(newUserId, forKey: "bitmovin_analytics_user_id")
        return newUserId
        
        
    }
}

extension Date {
    var timeIntervalSince1970Millis: Int64 {
        return Int64(round(Date().timeIntervalSince1970 * 1000))
    }
}
