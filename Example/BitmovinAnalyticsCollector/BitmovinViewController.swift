import Foundation
import BitmovinPlayer
import BitmovinAnalyticsCollector
import UIKit

class BitmovinViewController: UIViewController {
    var player: BitmovinPlayer?
    private var analyticsCollector: BitmovinAnalytics
    private var config: BitmovinAnalyticsConfig
    let url = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
    @IBOutlet var playerView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reloadButton: UIButton!

    deinit {
        player?.destroy()
    }

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: "9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac")
        config.cdnProvider = "custom_cdn_provider"
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "iOSHLSStaticBitmovin"
        config.path = "/vod/breadcrumb/"
        analyticsCollector = BitmovinAnalytics(config: config)

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let streamUrl = url else {
            return
        }

        self.playerView.backgroundColor = .black

        // Create player configuration
        let config = PlayerConfiguration()

        do {
            try config.setSourceItem(url: streamUrl)

            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)

            analyticsCollector.attachBitmovinPlayer(player: player)

            // Create player view and pass the player instance to it
            let playerBoundary = BMPBitmovinPlayerView(player: player, frame: .zero)

            playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerBoundary.frame = playerView.bounds

            playerView.addSubview(playerBoundary)
            playerView.bringSubview(toFront: playerBoundary)

            self.player = player
        } catch {
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // Add ViewController as event listener
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove ViewController as event listener
        super.viewWillDisappear(animated)
    }

    @IBAction func doneButtonWasPressed(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func reloadButtonWasPressed(_: UIButton) {
        analyticsCollector.detachPlayer()

        guard let player = player else {
            return
        }

        // Define needed resources
        guard let streamUrl = url else {
            return
        }

        do {
            let config = PlayerConfiguration()
            try config.setSourceItem(url: streamUrl)

            // Create player based on player configuration
            self.player?.load(sourceConfiguration: config.sourceConfiguration)

            analyticsCollector.attachBitmovinPlayer(player: player)

        } catch {
        }
    }
}
