import Foundation

typealias HttpCompletionHandlerType = ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)

class HttpClient {
    func post(urlString: String, json: String, completionHandler: HttpCompletionHandlerType?) {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("http://\(Util.mainBundleIdentifier())", forHTTPHeaderField: "Origin")
        request.httpMethod = "POST"
        request.httpBody = json.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completionHandler?(data, response, error)
        }

        task.resume()
    }
}
