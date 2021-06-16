class UserDefaultUserIdProvider: UserIdProvider {
    private let defaults = UserDefaults(suiteName: "com.bitmovin.analytics.collector_defaults")
    private let userIdFromStore: String
    
    init() {
        if let idFromStore = defaults?.string(forKey: "user_id") {
            userIdFromStore = idFromStore
        } else {
            userIdFromStore = NSUUID().uuidString
            defaults?.set(userIdFromStore, forKey: "user_id")
        }
    }
    
    func getUserId() -> String {
        return userIdFromStore
    }
}
