import XCTest
import AVKit

@testable import BitmovinAnalyticsCollector

class CoreTests_iOS: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        XCTAssertEqual(BitmovinAnalyticsCollector.Util, <#T##expression2: Equatable##Equatable#>)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

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

