class MockUserIdProvider: UserIdProvider {
    private var getUserIdAction: (() -> String)? = nil
    func setActionForGetUserIdAction(action: @escaping () -> String) {
        getUserIdAction = action
    }
    
    func getUserId() -> String {
        guard getUserIdAction != nil else {
            return ""
        }
        
        return getUserIdAction!()
    }
}
