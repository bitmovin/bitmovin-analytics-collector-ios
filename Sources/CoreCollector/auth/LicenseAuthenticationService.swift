import Foundation

internal class LicenseAuthenticationService: AuthenticationService {
    private let logger = _AnalyticsLogger(className: "LicenseAuthenticationService")
    private let config: BitmovinAnalyticsConfig
    private let httpClient: HttpClient
    private let notificationCenter: NotificationCenter

    init(_ httpClient: HttpClient, _ config: BitmovinAnalyticsConfig, _ notificationCenter: NotificationCenter) {
        self.httpClient = httpClient
        self.config = config
        self.notificationCenter = notificationCenter
    }

    func authenticate() {
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

    private func handleLicenseCallResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        let granted = self.validateResponse(data, response, error)
        if granted {
            logger.i("Bitmovin Analytics license call successful")
            self.notificationCenter.post(name: .authenticationSuccess, object: self)
        } else {
            logger.e("Bitmovin Analytics license call failed")
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
                logger.e("Bitmovin Analytics licensing failed. Could not decode JSON response: \(data)")
                return false
            }

            guard httpResponse.statusCode < 400 else {
                let message = json["message"] as? String
                logger.e("Bitmovin Analytics licensing failed. Reason: \(message ?? "Unknown error")")
                return false
            }

            guard let status = json["status"] as? String else {
                logger.e("Bitmovin Analytics licensing failed. Reason: status not set")
                return false
            }

            guard status == "granted" else {
                logger.e("Bitmovin Analytics licensing failed. Reason given by server: \(status)")
                return false
            }

            return true
        } catch {
            return false
        }
    }

    private func buildAuthenticationData() -> LicenseCallData {
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
