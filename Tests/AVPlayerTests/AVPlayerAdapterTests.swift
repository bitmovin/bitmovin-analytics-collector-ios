import XCTest
import AVKit
@testable import BitmovinAnalyticsCollector

class AVPlayerAdapterTests: XCTestCase {
    
    func testStopMonitoringWontFailOnMultipleCalls() throws {
        let player = AVPlayer()
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = AVPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        
        adapter.stopMonitoring()
        adapter.stopMonitoring()
    }
    
    func testStartMonitoringWontFailOnMultipleCalls() throws {
        let player = AVPlayer()
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = AVPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        
        adapter.startMonitoring()
        adapter.startMonitoring()
    }
}
