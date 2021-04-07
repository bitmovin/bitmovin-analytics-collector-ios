import Foundation

public class ErrorData {
    public var code: Int?
    public var message: String?
    public var data: String?
    
    static let ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED = ErrorData(code: 10000, message: "ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED", data: nil)
    static let ANALYTICS_BUFFERING_TIMEOUT_REACHED = ErrorData(code: 10001, message: "ANALYTICS_BUFFERING_TIMEOUT_REACHED", data: nil)
    static let ANALYTICS_VIDEOSTART_TIMEOUT_REACHED = ErrorData(code: 10002, message: "ANALYTICS_VIDEOSTART_TIMEOUT_REACHED", data: nil)
    
    init(code: Int?, message: String?, data: String?) {
        self.code = code
        self.message = message
        self.data = data
    }
}
