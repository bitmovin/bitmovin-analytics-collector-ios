import BitmovinPlayer
import BitmovinAnalyticsCollector
import UIKit

class BitmovinViewController: UIViewController {
    var player: Player?
    private var analyticsCollector: BitmovinPlayerCollector
    private var config: BitmovinAnalyticsConfig
    private let debugger: DebugBitmovinPlayerEvents = DebugBitmovinPlayerEvents()
    
//    private let redbullSource = SourceFactory.create(from: SourceConfig(url: URL(string: VideoAssets.redbull)!)!)
//    private let sintelSource = SourceFactory.create(from: SourceConfig(url: URL(string: VideoAssets.sintel)!)!)
    private let redbullCastSource = SourceFactory.create(from: SourceConfig(url: URL(string: VideoAssets.redbullCasting)!)!)
    private let sintelCastSource = SourceFactory.create(from: SourceConfig(url: URL(string: VideoAssets.sintelCasting)!)!)
    private let liveSimSource = SourceFactory.create(from: SourceConfig(url: URL(string: VideoAssets.liveSim)!)!)
    
    @IBOutlet var playerView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var seekToSecondSourceButton: UIButton!
    @IBOutlet var sourceChange: UIButton!
    @IBOutlet var setCustomData: UIButton!
    
    var adsActive = false

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
        config.videoId = "iOSHLSStaticBitmovin"
        config.title = "iOS HLS Static Asset with Bitmovin Player"
        config.path = "/vod/breadcrumb/"
        config.isLive = false
        config.ads = adsActive
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
    
    func attachAnalytics(player: Player) {
        print("attach Analytics to Player")
        // attach player to collector
        analyticsCollector.attachPlayer(player: player)
        
        // setup analytics SourceMetadata for redbull Source
        let redbullMetadata = SourceMetadata(
            title: "redbull",
            experimentName: "experiment-bitmovin-v3-upgrade")
        self.analyticsCollector.addSourceMetadata(playerSource: redbullCastSource, sourceMetadata: redbullMetadata)
        
        // setup analytics SourceMetadata for Sintel Source
        let sintelMetadata = SourceMetadata(videoId: "sintelID",
                                            title: "sintel",
                                            experimentName: "experiment-bitmovin-v3-upgrade")
        self.analyticsCollector.addSourceMetadata(playerSource: sintelCastSource, sourceMetadata: sintelMetadata)
    }
    
    func loadPlaylist(player: Player) {
        // Create playlistConfig
        guard let playlistConfig = getPlaylistConfig() else {
            return
        }
        
        // Load the playlist configuration into the player instance
        player.load(playlistConfig: playlistConfig)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.backgroundColor = .black
        
        // Create player configuration
        guard let config = getPlayerConfig(enableAds: adsActive) else {
            return
        }
            
        // Create player based on player configuration
        let player = PlayerFactory.create(playerConfig: config)

        // Listen to player events
        player.add(listener: debugger)
        
        self.player = player
        
        // Create player view and pass the player instance to it
        let playerBoundaries = BitmovinPlayer.PlayerView(player: player, frame: .zero)

        playerBoundaries.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundaries.frame = playerView.bounds

        playerView.addSubview(playerBoundaries)
        playerView.bringSubviewToFront(playerBoundaries)
        
        self.attachAnalytics(player: player)
        
        self.loadPlaylist(player: player)
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
        let playlistOptions = PlaylistOptions(preloadAllSources: false)
               
        return PlaylistConfig(
            sources: [redbullCastSource, sintelCastSource],
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
    
    @IBAction func sourceChangeWasPressed(_: UIButton) {
        // setup sourceMetadata important for analytics
        let liveMetadata = SourceMetadata(videoId: "liveSim",
                                          title: "liveSim",
                                          isLive: true,
                                          experimentName: "experiment-bitmovin-v3-upgrade")

        // add sourceMetadata to collector
        self.analyticsCollector.addSourceMetadata(playerSource: liveSimSource, sourceMetadata: liveMetadata)
        
        // load new source into player
        player?.load(source: liveSimSource)
    }
    
    @IBAction func seekToSecondSourceButtonWasPressed(_: UIButton) {
        guard let p = player else {
            return
        }
        
        if (p.playlist.sources.count < 2){
            return
        }
        
        let secondSource = p.playlist.sources[1]
        p.playlist.seek(source: secondSource, time: 10)
    }

    @IBAction func reloadButtonWasPressed(_: UIButton) {
        guard let player = player else {
            return
        }
        
        // detach player from collector to have new state
        analyticsCollector.detachPlayer()
        
        // unload current sources
        player.unload()
        
        self.attachAnalytics(player: player)
        
        self.loadPlaylist(player: player)
    }
    
    @IBAction func setCustomDataButtonWasPressed(_: UIButton) {
        let currentCustomData = analyticsCollector.getCustomData()
        currentCustomData.customData1 = "some test"
        currentCustomData.customData2 = "other test"
        analyticsCollector.setCustomDataOnce(customData: currentCustomData)
    }
}
