#if os(iOS)
import CoreTelephony
#endif

import AVKit
import Foundation

public class Util {
    static func mainBundleIdentifier() -> String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return "Unknown"
        }
        return bundleIdentifier
    }

    static func version() -> String {
        return BuildConfig.VERSION
    }

    static public func timeIntervalToCMTime(_ timeInterval: TimeInterval) -> CMTime? {
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

    static func getSupportedVideoCodecs() -> [String] {
        var codecs = ["avc"]
        if #available(iOS 11, tvOS 11, *) {
            codecs.append("hevc")
        }
        return codecs
    }

    static public func streamType(from url: String) -> StreamType? {
        var path = url.lowercased()
        if let components = URLComponents(string: url){
            path = components.path.lowercased()
        }

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
    
    static func getHostNameAndPath(uriString: String?) -> (String?, String?) {
        guard let uri = URL(string: uriString ?? "") else {
            return (nil, nil)
        }
        
        return (uri.host, uri.path)
    }
    
    static func calculatePercentage(numerator: Int64?, denominator: Int64?, clamp: Bool = false) -> Int? {
        if (denominator == nil || denominator == 0 || numerator == nil) {
            return nil;
        }
        let result = Int(Double(numerator!) / Double(denominator!) * 100)
        return clamp ? min(result, 100) : result;
    }
    
    static func calculatePercentageForTimeInterval(numerator: TimeInterval?, denominator: TimeInterval?, clamp: Bool = false) -> Int? {
        if (denominator == nil || denominator == 0 || numerator == nil) {
            return nil;
        }
        let result = Int(Double(numerator!) / Double(denominator!) * 100)
        return clamp ? min(result, 100) : result;
    }
}

extension Date {
    public var timeIntervalSince1970Millis: Int64 {
        return Int64(round(Date().timeIntervalSince1970 * 1_000))
    }
}

extension TimeInterval {
    public var milliseconds: Int64? {
        if self > Double(Int64.min) && self < Double(Int64.max) {
            return Int64(self * 1_000)
        }
        return nil
    }
}

func DPrint(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
