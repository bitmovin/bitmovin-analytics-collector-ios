import Foundation
import BitmovinPlayer
import BitmovinAnalyticsCollector
import UIKit

class BitmovinViewController: UIViewController {
    var player: Player?
    private var analyticsCollector: BitmovinPlayerCollector
    private var config: BitmovinAnalyticsConfig
    private let debugger: DebugBitmovinPlayerEvents = DebugBitmovinPlayerEvents()
    let url = URL(string: VideoAssets.sintel)
    let corruptedUrl = URL(string: VideoAssets.corruptRedBull)
    let liveSimUrl = URL(string: VideoAssets.liveSim)!
    @IBOutlet var playerView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var sourceChangeButton: UIButton!
    @IBOutlet var setCustomDataButton: UIButton!

    deinit {
        player?.destroy()
    }

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: "e73a3577-d91c-4214-9e6d-938fb936818a")
        config.cdnProvider = "custom_cdn_provider"
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customData6 = "customData6"
        config.customData7 = "customData7"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "iOSHLSStaticBitmovin"
        config.title = "iOS HLS Static Asset with Bitmovin Player"
        config.path = "/vod/breadcrumb/"
        config.isLive = false
        config.ads = true
        analyticsCollector = BitmovinPlayerCollector(config: config)
        print("Setup of collector finished")

        super.init(coder: aDecoder)
    }

    func getAdSource(url: String) -> AdSource {
        return AdSource(tag: urlWithCorrelator(adTag: url), ofType: BMPAdSourceType.IMA)
    }
    
    func getAdvertisingConfiguration() -> AdvertisingConfiguration {
        let preRoll = AdItem(adSources: [getAdSource(url: VideoAssets.AD_SOURCE_1)], atPosition: "pre")
//        let midRoll = AdItem(adSources: [adScource], atPosition: "mid")
        let customMidRoll = AdItem(adSources: [getAdSource(url: VideoAssets.AD_SOURCE_4)], atPosition: "10%")
//        let postRoll = AdItem(adSources: [adScource], atPosition: "post")

        return AdvertisingConfiguration(schedule: [preRoll, customMidRoll])
    }
    
    func urlWithCorrelator(adTag: String) -> URL {
        return URL(string: String(format: "%@%d", adTag, Int(arc4random_uniform(100000))))!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.backgroundColor = .black

        // Create player configuration
        guard let config = getPlayerConfig() else {
            return
        }
            
        // Create player based on player configuration
        let player = Player(configuration: config)

        player.add(listener: debugger)
        analyticsCollector.attachPlayer(player: player)
        // Create player view and pass the player instance to it
        let playerBoundary = BMPBitmovinPlayerView(player: player, frame: .zero)

        playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundary.frame = playerView.bounds

        playerView.addSubview(playerBoundary)
        playerView.bringSubviewToFront(playerBoundary)

        self.player = player
    }
    
    func getPlayerConfig(enableAds: Bool = false) -> PlayerConfiguration? {
        guard let streamUrl = url else {
            return nil
        }
        
        // Create player configuration
        let config = PlayerConfiguration()
        
        if (enableAds) {
            config.advertisingConfiguration = getAdvertisingConfiguration()
        }
        
        do {
            try config.setSourceItem(url: streamUrl)
            
            config.playbackConfiguration.isMuted = true
            config.playbackConfiguration.isAutoplayEnabled = false
        } catch {
            
        }
        
        return config
    }

    override func viewWillAppear(_ animated: Bool) {
        // Add ViewController as event listener
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove ViewController as event listener
        super.viewWillDisappear(animated)
    }
    
    @IBAction func sourceChangeButtonWasPressed(_: UIButton) {
        analyticsCollector.detachPlayer()
        player!.unload()
        
        config.title = "New video Title"
        let sourceConfig = SourceConfiguration()
        do {
            try sourceConfig.addSourceItem(url: liveSimUrl)
        }
        catch {}
        analyticsCollector.attachPlayer(player: self.player!)
        self.player!.load(sourceConfiguration: sourceConfig)
    }

    @IBAction func doneButtonWasPressed(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func reloadButtonWasPressed(_: UIButton) {
        analyticsCollector.detachPlayer()

        guard let player = player else {
            return
        }

        guard let config = getPlayerConfig() else {
            return
        }
        
        // Create player based on player configuration
        self.player?.load(sourceConfiguration: config.sourceConfiguration)

        analyticsCollector.attachPlayer(player: player)
    }
    
    @IBAction func setCustomDataButtonWasPressed(_: UIButton) {
        let currentCustomData = analyticsCollector.getCustomData()
        currentCustomData.customData1 = "some test"
        currentCustomData.customData2 = "other test"
        analyticsCollector.setCustomDataOnce(customData: currentCustomData)
    }
}
