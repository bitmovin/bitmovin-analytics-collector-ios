import BitmovinPlayer
import BitmovinAnalyticsCollector
import UIKit

class BitmovinViewController: UIViewController {
    var player: Player?
    private var analyticsCollector: BitmovinPlayerCollector
    private var config: BitmovinAnalyticsConfig
    private let debugger: DebugBitmovinPlayerEvents = DebugBitmovinPlayerEvents()

    @IBOutlet var playerView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reloadButton: UIButton!

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
        config.ads = false
        analyticsCollector = BitmovinPlayerCollector(config: config)
        print("Setup of collector finished")

        super.init(coder: aDecoder)
    }
    
    func getAdvertisingConfiguration() -> AdvertisingConfig {
        let adScource = AdSource(tag: urlWithCorrelator(adTag: AdAssets.SINGLE_SKIPPABLE_INLINE), ofType: AdSourceType.ima)
        
        let preRoll = AdItem(adSources: [adScource], atPosition: "pre")
//        let midRoll = AdItem(adSources: [adScource], atPosition: "mid")
//        let customMidRoll = AdItem(adSources: [adScource], atPosition: "10%")
//        let postRoll = AdItem(adSources: [adScource], atPosition: "post")
        return AdvertisingConfig(schedule: [preRoll])
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
        
        // Create playlistConfig
        guard let playlistConfig = getPlaylistConfig() else {
            return
        }
            
        // Create player based on player configuration
        let player = PlayerFactory.create(playerConfig: config)

        // Listen to player events
        player.add(listener: debugger)
        
        // attach player to collector
        analyticsCollector.attachPlayer(player: player)
        
        // Create player view and pass the player instance to it
        let playerBoundaries = BitmovinPlayer.PlayerView(player: player, frame: .zero)

        playerBoundaries.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundaries.frame = playerView.bounds

        playerView.addSubview(playerBoundaries)
        playerView.bringSubviewToFront(playerBoundaries)
        
        // Load the playlist configuration into the player instance
        player.load(playlistConfig: playlistConfig)

        self.player = player
    }
    
    func getPlayerConfig(enableAds: Bool = false) -> PlayerConfig? {
        // Create player configuration
        let config = PlayerConfig()
        
        if (enableAds) {
            config.advertisingConfig = getAdvertisingConfiguration()
        }
    
        config.playbackConfig.isMuted = true
        config.playbackConfig.isAutoplayEnabled = false
        
        return config
    }
    
    func getPlaylistConfig() -> PlaylistConfig? {
        guard let streamUrl = URL(string: VideoAssets.redbull) else {
            return nil
        }
        guard let streamUrl2 = URL(string: VideoAssets.sintel) else {
            return nil
        }
        
        
        let sourceConfig = SourceConfig(url: streamUrl)!
        let source = SourceFactory.create(from: sourceConfig)
        let sourceConfig2 = SourceConfig(url: streamUrl2)!
        let source2 = SourceFactory.create(from: sourceConfig2)
        
        let playlistOptions = PlaylistOptions(preloadAllSources: false)
               
        return PlaylistConfig(
            sources: [source, source2],
           options: playlistOptions
        )
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
        guard let player = player else {
            return
        }
        
        guard let playlistConfig = getPlaylistConfig() else {
            return
        }
        
        // detach player from collector to have new state
        analyticsCollector.detachPlayer()
        
        // unload current sources
        player.unload()
        
        // attach player to collector before loading new playlist/sources
        analyticsCollector.attachPlayer(player: player)
        
        // Load new playlist
        player.load(playlistConfig: playlistConfig)
    }
}
