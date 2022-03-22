import Foundation

public class DeviceInformationDto: Codable {
    var manufacturer: String
    var model: String
    var isTV: Bool
    var operatingSystem: String
    var operatingSystemMajor: String
    var operatingSystemMinor: String
    var deviceClass: DeviceClass
    
    init(manufacturer: String, model: String, isTV: Bool, operatingSystem: String, operatingSystemMajorVersion: String, operatingSystemMinorVersion: String, deviceClass: DeviceClass) {
        self.manufacturer = manufacturer
        self.model = model
        self.isTV = isTV
        self.operatingSystem = operatingSystem
        self.operatingSystemMajor = operatingSystemMajorVersion
        self.operatingSystemMinor = operatingSystemMinorVersion
        self.deviceClass = deviceClass
    }
}
