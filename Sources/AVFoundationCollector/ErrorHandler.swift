import Foundation

// Main purpose of this class is to keep track of errors and only send them out once per minute
// this solves issues with one error repeatedly occuring too often whitout losing track of the error itself
internal class ErrorHandler {
    private let ANALYTICS_ERROR_TIMEOUT = 10_000 // 10 sec
    private var errorMap: [Int: Int64] = [Int: Int64]()

    func shouldSendError(errorCode: Int) -> Bool {
        let now = Date().timeIntervalSince1970Millis
        if let errorTimestamp = errorMap[errorCode] {
            let diffSinceErrorOccured = now - errorTimestamp
            if diffSinceErrorOccured < ANALYTICS_ERROR_TIMEOUT {
                errorMap[errorCode] = now
                return false
            }
        }

        errorMap[errorCode] = now
        return true
    }
}
