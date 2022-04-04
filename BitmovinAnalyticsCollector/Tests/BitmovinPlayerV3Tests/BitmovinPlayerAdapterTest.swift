import XCTest
import BitmovinPlayer
#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import BitmovinPlayerCollector
@testable import CoreCollector
#endif

class BitmovinPlayerAdapterTests: XCTestCase {
    private let redbullSource = SourceFactory.create(from: SourceConfig(url: URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!)!)

    
    func testStopMonitoringWontFailOnMultipleCalls() throws {
        let playerConfig = PlayerConfig()
        playerConfig.key = "asdf"
        let player = PlayerFactory.create(playerConfig: playerConfig)
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine, sourceMetadataProvider: SourceMetadataProvider<Source>())
        
        adapter.stopMonitoring()
        adapter.stopMonitoring()
    }
    
    func testStartMonitoringWontFailOnMultipleCalls() throws {
        let playerConfig = PlayerConfig()
        playerConfig.key = "asdf"
        let player = PlayerFactory.create(playerConfig: playerConfig)
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = BitmovinPlayerAdapter(player: player, config: config, stateMachine: stateMachine, sourceMetadataProvider: SourceMetadataProvider<Source>())
        
        adapter.startMonitoring()
        adapter.startMonitoring()
    }
}
