public enum UserIdProviderFactory {
    public static func create(randomizeUserId: Bool) -> UserIdProvider {
        randomizeUserId ? RandomizedUserIdProvider() : UserDefaultUserIdProvider()
    }
}
