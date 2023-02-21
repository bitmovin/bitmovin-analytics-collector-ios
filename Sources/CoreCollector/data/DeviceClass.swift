import Foundation

public enum DeviceClass: String, Codable {
    case television = "TV"
    case phone = "Phone"
    case tablet = "Tablet"
    case wearable = "Wearable"
    case desktop = "Desktop"
    case console = "Console"
    case other = "Other"
}
