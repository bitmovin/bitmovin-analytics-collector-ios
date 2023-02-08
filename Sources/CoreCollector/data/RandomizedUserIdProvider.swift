import Foundation

class RandomizedUserIdProvider: UserIdProvider {
    private let userId = NSUUID()
    func getUserId() -> String {
        return userId.uuidString
    }
}
