import Foundation

public class DeviceInformationProvider {
    public var userAgent: String
    public var locale: String
    public var domain: String

    init(playerName: String, playerVersion: String, userAgent: String) {
        self.locale = Locale.current.languageCode!
        self.domain = Bundle.main.bundleIdentifier!
        self.userAgent = userAgent
    }
    
    /*public static func getUserAgent(playerName: String, playerVersion: String, operatingSystem: String) -> String {
        let infoDict = Bundle.main.infoDictionary!
        let appName = infoDict["CFBundleName"] as! String
        let appVersion = infoDict["CFBundleShortVersionString"] as! String

        let playerVersion = "0"
        return "\(appName)/\(appVersion) (Apple;\(operatingSystem)) \(playerName)/\(playerVersion)"
    }*/
    
    public func getDeviceInformation() -> DeviceInformationDto {
        // TODO: Should we move getDeviceClass() here?
        return DeviceInformationDto(manufacturer: "Apple",
                                    model: UIDevice.current.model,
                                    isTV: UIDevice.current.userInterfaceIdiom == .tv,
                                    operatingSystem: UIDevice.current.systemName,
                                    operatingSystemMajorVersion: String(ProcessInfo().operatingSystemVersion.majorVersion),
                                    operatingSystemMinorVersion: String(ProcessInfo().operatingSystemVersion.minorVersion),
                                    deviceClass: getDeviceClass()
        )
    }
}
