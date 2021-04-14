import Foundation
import BitmovinPlayer

public class BitmovinPlayerUtil {

    static func playerVersion() -> String? {
        let bundle = Bundle.allFrameworks.filter { bundle in
            return bundle.bundleIdentifier == "com.bitmovin.player"
        }
        if let version = bundle.first?.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }

        return "invalid"
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
    
    static func getAdTagTypeFromAdTag(adTag: AdTag)-> AnalyticsAdTagType {
        switch adTag.type {
            case AdTagType.vast:
                return AnalyticsAdTagType.VAST;
            case AdTagType.vmap:
                return AnalyticsAdTagType.VMAP;
            default:
                return AnalyticsAdTagType.UNKNOWN;
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
