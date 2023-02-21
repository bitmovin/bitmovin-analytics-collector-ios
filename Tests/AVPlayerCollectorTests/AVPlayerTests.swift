import AVKit
import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import AVPlayerCollector
@testable import CoreCollector
#endif

class AVPlayerTest: XCTestCase {
    func testCollectorWontCrashOnDetachPlayerIfNoPlayerIsAttached() {
        let collector = AVPlayerCollector(config: BitmovinAnalyticsConfig(key: ""))
        collector.detachPlayer()
    }

    func testCollectorWontCrashOnMultipleDetachPlayerCalls() {
        let player = AVPlayer()
        let collector = AVPlayerCollector(config: BitmovinAnalyticsConfig(key: ""))
        collector.attachPlayer(player: player)
        collector.detachPlayer()
        collector.detachPlayer()
    }

    func testCollectorWontCallDetachPlayerMultipleTimesOnPlayAttemptFailed() {
        let player = AVPlayer()
        let collector = AVPlayerCollector(config: BitmovinAnalyticsConfig(key: ""))
        collector.attachPlayer(player: player)
        player.play()
        collector.detachPlayer()
    }
}
