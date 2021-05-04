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
                return .pre;
            case "post":
                return .post;
            case "mid":
                return .mid;
            default:
                return .mid;
        }
    }
    
    static func getAdTagTypeFromAdTag(adTag: AdTag)-> AnalyticsAdTagType {
        switch adTag.type {
            case .vast:
                return .VAST;
            case .vmap:
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
