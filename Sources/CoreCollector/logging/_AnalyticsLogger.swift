import Foundation
import os.log

public class _AnalyticsLogger {
    private static let osLogCollector = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "BitmovinAnalyticsCollector")
    private let className: String

    public init(className: String) {
        self.className = className
    }

    public func i(_ message: String) {
        printLog(message, type: .info)
    }

    public func d(_ message: String) {
        printLog(message, type: .debug)
    }

    public func e(_ message: String) {
        printLog(message, type: .error)
    }

    public func f(_ message: String) {
        printLog(message, type: .fault)
    }

    private func printLog(_ message: String, type: OSLogType) {
        os_log("[%@] %@", log: Self.osLogCollector, type: type, className, message)
    }
}
