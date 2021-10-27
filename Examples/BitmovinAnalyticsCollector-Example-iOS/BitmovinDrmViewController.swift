import Foundation
import BitmovinPlayer
import BitmovinAnalyticsCollector
import UIKit

class BitmovinDrmViewController: UIViewController {
    var player: Player?
    private var analyticsCollector: BitmovinPlayerCollector
    private var config: BitmovinAnalyticsConfig
    private let debugger: DebugBitmovinPlayerEvents

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
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-with-drm"
        config.videoId = "iOSHLSStaticBitmovinDRM"
        config.title = "iOS HLS Static Asset with Bitmovin Player and DRM"
        config.path = "/vod/breadcrumb/"
        config.isLive = false
        config.ads = false
        analyticsCollector = BitmovinPlayerCollector(config: config)
        debugger = DebugBitmovinPlayerEvents()
        print("Setup of collector finished")

        super.init(coder: aDecoder)
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
        // Create player view and pass the player instance
        let playerBoundary = BMPBitmovinPlayerView(player: player, frame: .zero)

        playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundary.frame = playerView.bounds

        playerView.addSubview(playerBoundary)
        playerView.bringSubviewToFront(playerBoundary)

        self.player = player
    }
    
    func getPlayerConfig() -> PlayerConfiguration? {
        guard let streamUrl = drmStreamUrl else {
            return nil
        }
        
        // Create player configuration
        let config = PlayerConfiguration()
        
        // Setup DRM system
        let fpsConfig = FairplayConfiguration(
            license: drmLicenseUrl!,
            certificateURL: drmCertificateUrl!)
        
        fpsConfig.prepareContentId = { (contentId: String) -> String in
            return contentId.components(separatedBy: "/").last ?? contentId
        }
        fpsConfig.prepareCertificate = { (certificateData: Data) -> Data in
            guard let stringData = String(data: certificateData, encoding: .utf8),
                  let result = Data(base64Encoded: stringData.components(separatedBy: "\"").joined()) else {
                return certificateData
            }
            return result
        }
        fpsConfig.prepareMessage = { (data: Data, contentId: String) -> Data in
            return data.base64EncodedData()
        }
        fpsConfig.prepareLicense = { (licenseData: Data) -> Data in
            guard let stringData = String(data: licenseData, encoding: .utf8),
                  let result = Data(base64Encoded: stringData.components(separatedBy: "\"").joined()) else {
                return licenseData
            }
            return result
        }
        
        // Create SourceItem and add DRM
        let sourceItem = SourceItem(url: streamUrl)
        sourceItem?.add(drmConfiguration: fpsConfig)
        config.sourceItem = sourceItem
        
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

    @IBAction func doneButtonWasPressed(_ : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reloadButtonWasPressed(_ : UIButton) {
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
}
