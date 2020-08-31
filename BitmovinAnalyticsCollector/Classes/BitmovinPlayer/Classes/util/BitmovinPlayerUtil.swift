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
                return AdPosition.pre
            case "post":
                return AdPosition.post;
            case "mid":
                return AdPosition.mid;
            default:
                return AdPosition.mid;
        }
    }
    
    static func getAdTagTypeFromAdTag(adTag: AdTag)-> AdTagType {
        switch adTag.type {
            case BMPAdTagType.VAST:
                return AdTagType.VAST;
            case BMPAdTagType.VMAP:
                return AdTagType.VMAP;
            default:
                return AdTagType.UNKNOWN;
        }
    }
    
    static func getAdQuartileFromPlayerAdQuartile(adQuartile: AdQuartile) -> AnalyticsAdQuartile {
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
