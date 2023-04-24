import AVKit
import Nimble
import Quick



#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class AVPlayerAdapterTests: QuickSpec {
    override func spec() {
        describe("stopMonitoring") {
            it("should not fail on multiple calls") {
                // arrange
                let player = AVPlayer()
                let config = BitmovinAnalyticsConfig(key: "")
                let playerContext = MockPlayerContext()
                let stateMachine = DefaultStateMachine(playerContext: playerContext)
                let adapter = self.createAdapter(stateMachine, player)

                // act
                adapter.stopMonitoring()

                // assert (second call)
                expect { adapter.stopMonitoring() }.notTo(throwError())
            }
        }
    }

    private func createAdapter(
        _ stateMachine: StateMachine,
        _ player: AVPlayer
    ) -> AVPlayerAdapter {
        let eventDataFactory = EventDataFactory(BitmovinAnalyticsConfig(key: ""), UserDefaultUserIdProvider())
        let analytics = BitmovinAnalyticsInternal.createAnalytics(
            config: BitmovinAnalyticsConfig(key: "test-key"),
            eventDataFactory: eventDataFactory
        )
        return AVPlayerAdapterFactory.createAdapter(
            analytics: analytics,
            eventDataFactory: eventDataFactory,
            player: player
        )
    }
}
