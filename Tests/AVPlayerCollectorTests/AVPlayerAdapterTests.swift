import AVKit
import Nimble
import Quick

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

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
                let stateMachine = DefaultStateMachine()
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
        return AVPlayerAdapterFactory.createAdapter(
            stateMachine: stateMachine,
            eventDataFactory: eventDataFactory,
            player: player
        )
    }
}
