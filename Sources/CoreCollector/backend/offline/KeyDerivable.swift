import Foundation

internal protocol KeyDerivable {
    var queueKey: LosslessStringConvertible? { get }
}
