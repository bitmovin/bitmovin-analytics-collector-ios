import Foundation

enum ErrorCode: Int {
    
    case ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED = 10000
    case ANALYTICS_BUFFERING_TIMEOUT_REACHED = 10001
    
    func getErrorObject() -> [AnyHashable: Any] {
        var errorObject: [AnyHashable: Any] = [BitmovinAnalyticsInternal.ErrorCodeKey: self.rawValue]
        switch self {
            case .ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED:
                errorObject[BitmovinAnalyticsInternal.ErrorMessageKey] = "ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED"
            case .ANALYTICS_BUFFERING_TIMEOUT_REACHED:
                errorObject[BitmovinAnalyticsInternal.ErrorMessageKey] = "ANALYTICS_BUFFERING_TIMEOUT_REACHED"
        }
        
        return errorObject
    }
}
