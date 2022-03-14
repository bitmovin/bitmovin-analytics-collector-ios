import Foundation

public enum DeviceClass: String {
    case TV = "TV"
    case Phone = "Phone"
    case Tablet = "Tablet"
    case Wearable = "Wearable"
    case Desktop = "Desktop"
    case Console = "Console"
    case Other = "Other"
}

public func getDeviceClass() -> DeviceClass {
    switch UIDevice.current.userInterfaceIdiom {
    case .tv:
        return DeviceClass.TV
    case .phone:
        return DeviceClass.Phone
    case .pad:
        return DeviceClass.Tablet
    case .mac:
        return DeviceClass.Desktop
    default:
        return DeviceClass.Other
    }
}
