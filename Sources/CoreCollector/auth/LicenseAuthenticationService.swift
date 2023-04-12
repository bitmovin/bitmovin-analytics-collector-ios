import Foundation

internal class LicenseAuthenticationService: AuthenticationService {
    private enum LicenseStatus{
        // The license was denied
        case denied
        // The license was granted
        case granted
        // There was an error while trying to authenticate. This could indicate missing network access
        case error
    }

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
        let licenseStatus = self.validateResponse(data, response, error)

        switch licenseStatus {
        case .granted:
            logger.i("Bitmovin Analytics license call successful")
            self.notificationCenter.post(name: .authenticationSuccess, object: self)
        case .denied:
            logger.e("Bitmovin Analytics license call denied")
            self.notificationCenter.post(name: .authenticationDenied, object: self)
        case .error:
            logger.e("Bitmovin Analytics license call failed with error")
            self.notificationCenter.post(name: .authenticationError, object: self)
        }
    }

    private func validateResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> LicenseStatus {
        guard error == nil else { // check for fundamental networking error
            return .error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .error
        }

        guard let data = data else {
            return .error
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                logger.e("Bitmovin Analytics licensing failed. Could not decode JSON response: \(data)")
                return .error
            }

            guard httpResponse.statusCode < 400 else {
                let message = json["message"] as? String
                logger.e("Bitmovin Analytics licensing failed. Reason: \(message ?? "Unknown error")")
                return .error
            }

            guard let status = json["status"] as? String else {
                logger.e("Bitmovin Analytics licensing failed. Reason: status not set")
                return .error
            }

            guard status == "granted" else {
                logger.e("Bitmovin Analytics licensing failed. Reason given by server: \(status)")
                return .denied
            }

            return .granted
        } catch {
            return .error
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

internal extension Notification.Name {
    static let authenticationDenied = Notification.Name("AuthenticationService.denied")
    static let authenticationError = Notification.Name("AuthenticationService.error")
    static let authenticationSuccess = Notification.Name("AuthenticationService.success")
}
