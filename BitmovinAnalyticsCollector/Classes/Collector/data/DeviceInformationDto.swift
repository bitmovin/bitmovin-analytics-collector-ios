import Foundation

class DeviceInformationDto: Codable {
    var manufacturer: String
    var model: String
    var isTV: Bool
    var operatingSystem: String
    var operatingSystemMajor: String
    var operatingSystemMinor: String
    var deviceClass: DeviceClass
    
    init(manufacturer: String, model: String, isTV: Bool, osName: String, osMajorVersion: String, osMinorVersion: String, deviceClass: DeviceClass) {
        self.manufacturer = manufacturer
        self.model = model
        self.isTV = isTV
        self.operatingSystem = osName
        self.operatingSystemMajor = osMajorVersion
        self.operatingSystemMinor = osMinorVersion
        self.deviceClass = deviceClass
    }
    
    public static func fromDeviceInformation(_ info: DeviceInformation) -> DeviceInformationDto {
        return DeviceInformationDto(manufacturer: info.manufacturer,
                                    model: info.model,
                                    isTV: info.isTV,
                                    osName: info.operatingSystem,
                                    osMajorVersion: info.operatingSystemMajor,
                                    osMinorVersion: info.operatingSystemMinor,
                                    deviceClass: info.deviceClass
        )
    }
}
