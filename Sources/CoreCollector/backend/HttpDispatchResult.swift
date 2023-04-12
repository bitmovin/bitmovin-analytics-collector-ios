internal enum HttpDispatchResult {
    case success(code: Int)
    case failure(code: Int?, error: Error?)
}
