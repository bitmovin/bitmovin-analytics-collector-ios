
import Foundation

typealias LicenseCallCompletionHandler = ((_ success: Bool) -> Void)

class LicenseCall {
    var config: BitmovinAnalyticsConfig
    var httpClient: HttpClient

    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        httpClient = HttpClient(urlString: BitmovinAnalyticsConfig.analyticsLicenseUrl)
    }

    public func authenticate(_ completionHandler: @escaping LicenseCallCompletionHandler) {
        let licenseCallData = LicenseCallData()
        licenseCallData.key = config.key
        licenseCallData.domain = Util.mainBundleIdentifier()
        licenseCallData.analyticsVersion = Util.version()
        httpClient.post(json: Util.toJson(object: licenseCallData)) { data, response, error in
            guard error == nil else { // check for fundamental networking error
                completionHandler(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(false)
                return
            }

            if httpResponse.statusCode >= 400 {
                completionHandler(false)
            }

            guard let data = data else {
                completionHandler(false)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                if let status = json["status"] as? String {
                    return completionHandler(status == "granted")
                }
            } catch {
                completionHandler(false)
            }
        }
    }
}

extension Notification.Name {
    static let licenseFailed = Notification.Name("licenseFailed")
}
