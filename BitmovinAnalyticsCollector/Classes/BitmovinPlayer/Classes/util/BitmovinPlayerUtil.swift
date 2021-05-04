import Foundation
import BitmovinPlayer

public class BitmovinPlayerUtil {

    static func playerVersion() -> String? {
        return Bundle(for: Player.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static func getAdPositionFromString(string: String?)-> AdPosition? {
        if (string == nil) {
            return nil;
        }
        switch string {
            case "pre":
                return .pre;
            case "post":
                return .post;
            case "mid":
                return .mid;
            default:
                return .mid;
        }
    }
    
    static func getAdTagTypeFromAdTag(adTag: AdTag)-> AdTagType {
        switch adTag.type {
            case .VAST:
                return .VAST;
            case .VMAP:
                return .VMAP;
            default:
                return .UNKNOWN;
        }
    }
    
    static func getAdQuartileFromPlayerAdQuartile(adQuartile: AdQuartile) -> AnalyticsAdQuartile {
        switch adQuartile {
            case .firstQuartile:
                return .FIRST_QUARTILE;
            case .midpoint:
                return .MIDPOINT;
            case .thirdQuartile:
                return .THIRD_QUARTILE;
            @unknown default:
                fatalError()
        }
    }
}
