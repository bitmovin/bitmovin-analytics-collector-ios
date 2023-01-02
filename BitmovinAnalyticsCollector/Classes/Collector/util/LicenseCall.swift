import Foundation

typealias LicenseCallCompletionHandler = ((_ success: Bool) throws -> Void) 

func DPrint(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}

class LicenseCall {
    var config: BitmovinAnalyticsConfig
    var httpClient: HttpClient
    var analyticsLicenseUrl: String

    init(config: BitmovinAnalyticsConfig) {
        self.config = config
        httpClient = HttpClient()
        self.analyticsLicenseUrl = BitmovinAnalyticsConfig.analyticsLicenseUrl
    }

    public func authenticate(_ completionHandler: @escaping LicenseCallCompletionHandler) {
        let licenseCallData = LicenseCallData()
        licenseCallData.key = config.key
        licenseCallData.domain = Util.mainBundleIdentifier()
        licenseCallData.analyticsVersion = Util.version()
        httpClient.post(urlString: self.analyticsLicenseUrl, json: Util.toJson(object: licenseCallData)) { [weak self] data, response, error in
            guard let licenseCall = self else {
                return
            }
            
            let granted = licenseCall.validateResponse(data, response, error)
            do {
                try completionHandler(granted)
            } catch {
                DPrint("error handling license call")
            }
        }
    }
    
    private func validateResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool {
        guard error == nil else { // check for fundamental networking error
            return false
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        guard let data = data else {
            return false
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                DPrint("Licensing failed. Could not decode JSON response: \(data)")
                return false
            }
            
            guard httpResponse.statusCode < 400 else {
                let message = json["message"] as? String
                DPrint("Licensing failed. Reason: \(message ?? "Unknown error")")
                return false
            }
            
            guard let status = json["status"] as? String else {
                DPrint("Licensing failed. Reason: status not set")
                return false
            }
            
            guard status == "granted" else {
                DPrint("Licensing failed. Reason given by server: \(status)")
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
}

extension Notification.Name {
    static let licenseFailed = Notification.Name("licenseFailed")
}
