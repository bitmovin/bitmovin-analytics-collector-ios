import Foundation

public class ErrorData {
    var code: Int?
    var message: String?
    var data: String?

    static let QUALITY_CHANGE_THRESHOLD_EXCEEDED = ErrorData(code: 10_000, message: "ANALYTICS_QUALITY_CHANGE_THRESHOLD_EXCEEDED", data: nil)
    static let BUFFERING_TIMEOUT_REACHED = ErrorData(code: 10_001, message: "ANALYTICS_BUFFERING_TIMEOUT_REACHED", data: nil)
    static let VIDEOSTART_TIMEOUT_REACHED = ErrorData(code: 10_002, message: "ANALYTICS_VIDEOSTART_TIMEOUT_REACHED", data: nil)

    public init(code: Int?, message: String?, data: String?) {
        self.code = code
        self.message = message
        self.data = data
    }
}
