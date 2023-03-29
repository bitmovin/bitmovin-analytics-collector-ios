import XCTest
#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import CoreCollector
#endif

class CorePlayerAdapterTests: XCTestCase {
    func testDestroyWontFailOnMultipleCalls() throws {
        let config = BitmovinAnalyticsConfig(key: "")
        let mockPlayerContext = MockPlayerContext()
        let stateMachine = DefaultStateMachine(playerContext: mockPlayerContext)
        let adapter = CorePlayerAdapter(stateMachine: stateMachine)

        adapter.destroy()
        adapter.destroy()
    }
}
