#if os(iOS)
import CoreTelephony
#endif

import AVKit
import Foundation
import BitmovinPlayer

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
    
    static func playerVersion() -> String?{
        return Bundle(for: BitmovinPlayer.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    static func timeIntervalToCMTime(_ timeInterval: TimeInterval) -> CMTime? {
        if !timeInterval.isNaN, !timeInterval.isInfinite {
            return CMTimeMakeWithSeconds(timeInterval, preferredTimescale: 1000)
        }
        return nil
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
        let defaults = UserDefaults(suiteName: "com.bitmovin.analytics.collector_defaults")
        if let userIdFromStore = defaults?.string(forKey: "user_id") {
            return userIdFromStore
        }

        let newUserId = NSUUID().uuidString
        defaults?.set(newUserId, forKey: "user_id")
        return newUserId
    }
    
    static func getUUID() -> String{
        return NSUUID().uuidString
    }

    static func getSupportedVideoCodecs() -> [String] {
        var codecs = ["avc"]
        if #available(iOS 11, tvOS 11, *) {
            codecs.append("hevc")
        }
        return codecs
    }

    static func streamType(from url: String) -> StreamType? {
        let path = url.lowercased()

        if path.hasSuffix(".m3u8") {
            return StreamType.hls
        }
        if path.hasSuffix(".mp4") || path.hasSuffix(".m4v") || path.hasSuffix(".m4a") || path.hasSuffix(".webm") {
            return StreamType.progressive
        }
        if path.hasSuffix(".mpd") {
            return StreamType.dash
        }
        return nil
    }
    
    static func getHostNameAndPath(uriString: String?) -> (String?, String?){
        guard let uri = URL(string: uriString ?? "") else {
            return (nil, nil)
        }
        
        return (uri.host, uri.path)
    }
    
    static func calculatePercentage(numerator: Int64?, denominator: Int64?, clamp: Bool = false) -> Int?{
        if (denominator == nil || denominator == 0 || numerator == nil) {
            return nil;
        }
        let result = Int(round(Double(numerator!) / Double(denominator!)) * 100)
        return clamp ? min(result, 100) : result;
    }
    
    static func getAdPositionFromString(string: String?)-> AdPosition?{
         if(string == nil){
            return nil;
        }
        switch string {
        case "pre":
            return AdPosition.pre
        case "post":
            return AdPosition.post;
        case "mid":
            return AdPosition.mid;
        default:
            return AdPosition.mid;
        }
    }
    
    static func getAdTagTypeFromAdTag(adTag: AdTag)-> AdTagType{
        switch adTag.type {
        case BMPAdTagType.VAST:
            return AdTagType.VAST;
        case BMPAdTagType.VMAP:
            return AdTagType.VMAP;
        default:
            return AdTagType.UNKNOWN;
        }
    }
    
    static func getAdQuartileFromPlayerAdQuartile(adQuartile: AdQuartile) -> AnalyticsAdQuartile{
        switch adQuartile {
        case AdQuartile.firstQuartile:
            return AnalyticsAdQuartile.FIRST_QUARTILE;
        case AdQuartile.midpoint:
            return AnalyticsAdQuartile.MIDPOINT;
        case AdQuartile.thirdQuartile:
            return AnalyticsAdQuartile.THIRD_QUARTILE;
        @unknown default:
            fatalError()
        }
    }
}

extension Date {
    var timeIntervalSince1970Millis: Int64 {
        return Int64(round(Date().timeIntervalSince1970 * 1_000))
    }
}
