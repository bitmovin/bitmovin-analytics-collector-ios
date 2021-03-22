import XCTest
import AVKit
@testable import BitmovinAnalyticsCollector

class AVPlayerAdapterTests: XCTestCase {
    
    func test() {
        
        let player = AVPlayer()
        let config = BitmovinAnalyticsConfig(key: "")
        class StateMachineMock : StateMachine {
            override func transitionState(destinationState: PlayerState, time: CMTime?) {
                super.transitionState(destinationState: destinationState, time: time)
            }
        }
        let stateMachine = StateMachineMock(config: config)
        let adapter = AVPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        let expectation = XCTestExpectation()
        let url = URL(string: "http://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
        let asset = AVURLAsset(url: url!, options: nil)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let item = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: item)
                player.play()
                sleep(5) // to get the chance of some playback
            print(player.currentTime())
            
            player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1)) { (Bool) in
                print("seek finished")
                print(player.currentTime())
                sleep(5) // to get the chance of some playback
                print(player.currentTime())
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 20)
        
//        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
//
//        player.play()
//        Thread.sleep(forTimeInterval: 20)
//        player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1))
        adapter.destroy()
    }
    
    func testStopMonitoringWontFailOnMultipleCalls() throws {
        let player = AVPlayer()
        let config = BitmovinAnalyticsConfig(key: "")
        let stateMachine = StateMachine(config: config)
        let adapter = AVPlayerAdapter(player: player, config: config, stateMachine: stateMachine)
        
        adapter.stopMonitoring()
        adapter.stopMonitoring()
    }
}
