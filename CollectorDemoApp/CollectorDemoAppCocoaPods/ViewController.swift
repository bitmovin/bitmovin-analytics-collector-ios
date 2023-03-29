import Foundation
import UIKit
import BitmovinAnalyticsCollector
import BitmovinPlayer

class ViewController: UIViewController {
    private var player: Player?
    private var analyticsCollector: BitmovinAnalytics
    private var config: BitmovinAnalyticsConfig

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: AppConfig.analyticsLicenseKey)
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customData6 = "customData6"
        config.customData7 = "customData7"
        config.customData8 = "customData8"
        config.customData9 = "customData9"
        config.customData10 = "customData10"
        config.customData11 = "customData11"
        config.customData12 = "customData12"
        config.customData13 = "customData13"
        config.customData14 = "customData14"
        config.customData15 = "customData15"
        config.customData16 = "customData16"
        config.customData17 = "customData17"
        config.customData18 = "customData18"
        config.customData19 = "customData19"
        config.customData20 = "customData20"
        config.customData21 = "customData21"
        config.customData22 = "customData22"
        config.customData23 = "customData23"
        config.customData24 = "customData24"
        config.customData25 = "customData25"
        config.customData26 = "customData26"
        config.customData27 = "customData27"
        config.customData28 = "customData28"
        config.customData29 = "customData29"
        config.customData30 = "customData30"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "tvOSHLSStatic"
        config.path = "/vod/breadcrumb/"

        analyticsCollector = BitmovinAnalytics(config: config)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }

        // Create player configuration
        let config = PlayerConfig()
        let playbackConfig = PlaybackConfig()
        playbackConfig.isAutoplayEnabled = true

        config.playbackConfig = playbackConfig
        // Create player based on player configuration
        let player = PlayerFactory.create(playerConfig: config)
        player.mute()
        analyticsCollector.attachBitmovinPlayer(player: player)

        // Create player view and pass the player instance to it
        let playerBoundaries = BitmovinPlayer.PlayerView(player: player, frame: .zero)

        // Listen to player events

        playerBoundaries.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundaries.frame = view.bounds

        view.addSubview(playerBoundaries)
        view.bringSubviewToFront(playerBoundaries)

        let sourceConfig = SourceConfig(url: streamUrl)
        let source = SourceFactory.create(from: sourceConfig!)
        player.load(source: source)
        self.player = player
    }
}
