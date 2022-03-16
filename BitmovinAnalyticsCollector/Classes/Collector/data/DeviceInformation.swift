import Foundation

public class DeviceInformation {
    public let manufacturer = "Apple"
    public let model = UIDevice.current.model
    public let isTV = UIDevice.current.userInterfaceIdiom == .tv
    public var userAgent: String
    public var locale: String
    public var domain: String
    public let screenHeight = Int(UIScreen.main.nativeBounds.height)
    public let screenWidth = Int(UIScreen.main.nativeBounds.width)
    public let operatingSystem = UIDevice.current.systemName
    public let operatingSystemMajor = String(ProcessInfo().operatingSystemVersion.majorVersion)
    public let operatingSystemMinor = String(ProcessInfo().operatingSystemVersion.minorVersion)
    public var deviceClass: DeviceClass
    
    init(playerName: String, playerVersion: String) {
        self.locale = Locale.current.languageCode!
        self.domain = Bundle.main.bundleIdentifier!
        self.deviceClass = getDeviceClass()
        self.userAgent = DeviceInformation.getUserAgent(playerName: playerName, playerVersion: playerVersion, operatingSystem: self.operatingSystem)
    }
    
    public static func getUserAgent(playerName: String, playerVersion: String, operatingSystem: String) -> String {
        let infoDict = Bundle.main.infoDictionary!
        let appName = infoDict["CFBundleName"] as! String
        let appVersion = infoDict["CFBundleShortVersionString"] as! String

        let playerVersion = "0"
        return "\(appName)/\(appVersion) (Apple;\(operatingSystem)) \(playerName)/\(playerVersion)"
    }
}
