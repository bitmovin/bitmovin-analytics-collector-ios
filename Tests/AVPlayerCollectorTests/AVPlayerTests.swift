import AVKit
import XCTest
@testable import AVPlayerCollector
@testable import CoreCollector

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
