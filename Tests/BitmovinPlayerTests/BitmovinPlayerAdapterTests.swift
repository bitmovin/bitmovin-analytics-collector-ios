import XCTest
import BitmovinPlayer
@testable import BitmovinAnalyticsCollector

class BitmovinPlayerAdapterTests: XCTestCase {
    
    func testStopMonitoringWontFailOnMultipleCalls() throws {
        let playerConfig = PlayerConfiguration()
        playerConfig.key = "asdf"
        let player = Player(configuration: playerConfig)
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        
        adapter.stopMonitoring()
        adapter.stopMonitoring()
    }
    
    func testStartMonitoringWontFailOnMultipleCalls() throws {
        let playerConfig = PlayerConfiguration()
        playerConfig.key = "asdf"
        let player = Player(configuration: playerConfig)
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        
        adapter.startMonitoring()
        adapter.startMonitoring()
    }
}
