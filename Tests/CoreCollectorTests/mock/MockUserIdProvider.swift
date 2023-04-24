import CoreCollector

class MockUserIdProvider: UserIdProvider {
    private var getUserIdAction: (() -> String)?
    func setActionForGetUserId(action: @escaping () -> String) {
        getUserIdAction = action
    }

    func getUserId() -> String {
        guard getUserIdAction != nil else {
            return ""
        }

        return getUserIdAction!()
    }
}
