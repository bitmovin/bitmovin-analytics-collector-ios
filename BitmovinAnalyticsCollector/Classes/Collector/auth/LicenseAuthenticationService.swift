import Foundation

internal class LicenseAuthenticationService: AuthenticationService {
    private let config: BitmovinAnalyticsConfig
    private let httpClient: HttpClient
    private let notificationCenter: NotificationCenter
    
    init(httpClient: HttpClient, config: BitmovinAnalyticsConfig, notificationCenter: NotificationCenter){
        self.httpClient = httpClient
        self.config = config
        self.notificationCenter = notificationCenter
    }
    
    public func authenticate() {
        let licenseCallData = self.buildAuthenticationData()
        let json = Util.toJson(object: licenseCallData)
        let url = BitmovinAnalyticsConfig.analyticsLicenseUrl
        httpClient.post(urlString: url, json: json ) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            self.handleLicenseCallResponse(data, response, error)
        }
    }
    
    private func handleLicenseCallResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        let granted = self.validateResponse(data, response, error)
        if granted {
            DPrint("License Call: success")
            self.notificationCenter.post(name: .authenticationSuccess, object: self)
        } else {
            DPrint("License Call: failed")
            self.notificationCenter.post(name: .authenticationFailed, object: self)
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
    
    private func buildAuthenticationData() -> LicenseCallData{
        let licenseCallData = LicenseCallData()
        licenseCallData.key = config.key
        licenseCallData.domain = Util.mainBundleIdentifier()
        licenseCallData.analyticsVersion = Util.version()
        return licenseCallData
    }
}

extension Notification.Name {
    static let authenticationFailed = Notification.Name("AuthenticationService.failed")
    static let authenticationSuccess = Notification.Name("AuthenticationService.success")
}
