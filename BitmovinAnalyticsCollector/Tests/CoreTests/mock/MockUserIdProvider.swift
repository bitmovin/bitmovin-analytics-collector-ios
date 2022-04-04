#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif
#if SWIFT_PACKAGE
import CoreCollector
#endif

class MockUserIdProvider: UserIdProvider {
    private var getUserIdAction: (() -> String)? = nil
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
