import Foundation

internal protocol KeyDerivable {
    var derivedKey: LosslessStringConvertible? { get }
}
