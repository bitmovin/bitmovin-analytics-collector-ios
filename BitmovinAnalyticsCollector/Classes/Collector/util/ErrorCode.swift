import Foundation

struct ErrorCode {
    let code: Int
    let message: String
    
    static let ANALYTICS_BUFFERING_TIMEOUT_REACHED = ErrorCode(code: 10001, message: "ANALYTICS_BUFFERING_TIMEOUT_REACHED")
    
    var data: [Int: String] {
        return [BitmovinAnalyticsInternal.ErrorCodeKey: code,
                BitmovinAnalyticsInternal.ErrorMessageKey: message]
    }
}
