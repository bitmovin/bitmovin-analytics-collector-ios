import Foundation

internal enum HttpDispatchResult {
    case success(code: Int)
    case failure(code: Int?, error: Error?)

    static func from(data: Data?, response: URLResponse?, error: Error?) -> HttpDispatchResult {
        if let error {
            return .failure(code: nil, error: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(code: nil, error: nil)
        }

        let statusCode = httpResponse.statusCode

        guard (200..<300).contains(statusCode) else {
            return .failure(code: statusCode, error: nil)
        }

        return .success(code: statusCode)
    }
}
