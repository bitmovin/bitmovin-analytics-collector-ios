import CoreCollector
import BitmovinPlayerCollector
import BitmovinPlayer
import UIKit

class BitmovinDrmViewController: UIViewController {
    private let logger = _AnalyticsLogger(className: "BitmovinDrmViewController")
    var player: Player?
    private var analyticsCollector: BitmovinPlayerCollector
    private var config: BitmovinAnalyticsConfig
    private let debugger = DebugBitmovinPlayerEvents()

    // TODO: Add URLs
    let drmStreamUrl = URL(string: "")
    let drmLicenseUrl = URL(string: "")
    let drmCertificateUrl = URL(string: "")

    @IBOutlet var playerView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reloadButton: UIButton!

    deinit {
        player?.destroy()
    }

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: AppConfig.analyticsLicenseKey)
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
        config.experimentName = "experiment-with-drm"
        config.videoId = "iOSHLSStaticBitmovinDRM"
        config.title = "iOS HLS Static Asset with Bitmovin Player and DRM"
        config.path = "/vod/breadcrumb/"
        config.isLive = false
        config.ads = false
        config.playerKey = "a6e31908-550a-4f75-b4bc-a9d89880a733"
        analyticsCollector = BitmovinPlayerCollector(config: config)
        logger.d("Setup of collector finished")

        super.init(coder: aDecoder)
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

        // Create player view and pass the player instance
        let playerBoundary = BitmovinPlayer.PlayerView(player: player, frame: .zero)

        playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundary.frame = playerView.bounds

        playerView.addSubview(playerBoundary)
        playerView.bringSubviewToFront(playerBoundary)

        // Load the playlist configuration into the player instance
        player.load(playlistConfig: playlistConfig)

        self.player = player
    }

    func getPlayerConfig() -> PlayerConfig? {
        // Create player configuration
        let config = PlayerConfig()

        config.playbackConfig.isMuted = true
        config.playbackConfig.isAutoplayEnabled = false

        return config
    }

    func getPlaylistConfig() -> PlaylistConfig? {
        guard let streamUrl = drmStreamUrl else {
            return nil
        }

        let sourceConfig = SourceConfig(url: streamUrl)!

        // Setup DRM system
        let fpsConfig = FairplayConfig(
            license: drmLicenseUrl!,
            certificateURL: drmCertificateUrl!)

        fpsConfig.prepareContentId = { (contentId: String) -> String in
            contentId.components(separatedBy: "/").last ?? contentId
        }
        fpsConfig.prepareCertificate = { (certificateData: Data) -> Data in
            guard let stringData = String(data: certificateData, encoding: .utf8),
                  let result = Data(base64Encoded: stringData.components(separatedBy: "\"").joined()) else {
                return certificateData
            }
            return result
        }
        fpsConfig.prepareMessage = { (data: Data, _: String) -> Data in
            data.base64EncodedData()
        }
        fpsConfig.prepareLicense = { (licenseData: Data) -> Data in
            guard let stringData = String(data: licenseData, encoding: .utf8),
                  let result = Data(base64Encoded: stringData.components(separatedBy: "\"").joined()) else {
                return licenseData
            }
            return result
        }

        // assign the FairplayConfig to the sourceConfig
        sourceConfig.drmConfig = fpsConfig

        let source = SourceFactory.create(from: sourceConfig)

        let playlistOptions = PlaylistOptions(preloadAllSources: false)

        return PlaylistConfig(
            sources: [source],
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
