import AVKit
import CoreCollector
import AVPlayerCollector
import UIKit

class AVFoundationDrmViewController: UIViewController {
    // TODO: Add URLs
    let drmStreamUrl = URL(string: "")
    let drmLicenseUrl = URL(string: "")
    let drmCertificateUrl = URL(string: "")

    private var analyticsCollector: AVPlayerCollector
    private var config: BitmovinAnalyticsConfig

    private var asset: Asset?
    private var isSeeking = false
    private var timeObserverToken: Any?
    private static var playerViewControllerKVOContext = 0

    @IBOutlet var playerView: PlayerView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var fastForwardButton: UIButton!
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var endDuration: UILabel!
    @IBOutlet var position: UILabel!

    // MARK: - AssetPlaybackManager Variables

    /// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
    @objc private let player = AVPlayer()

    /**
     A Bool tracking if the AVPlayerItem.status has changed to
     .readyToPlay for the current AssetPlaybackManager.playerItem.
    */
    private var readyForPlayback = false

    /// The `NSKeyValueObservation` for the KVO on \AVPlayerItem.status.
    private var playerItemObserver: NSKeyValueObservation?

    /// The `NSKeyValueObservation` for the KVO on \AVURLAsset.isPlayable.
    private var urlAssetObserver: NSKeyValueObservation?

    /// The `NSKeyValueObservation` for the KVO on \AVPlayer.currentItem.
    private var playerObserver: NSKeyValueObservation?

    // MARK: Initialization

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
        config.experimentName = "experiment-with-drm"
        config.videoId = "iOSHLSStaticBitmovinDRM"
        config.title = "Static HLS Video on iOS"
        config.path = "/vod/breadcrumb/"
        config.isLive = true

        analyticsCollector = AVPlayerCollector(config: config)
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_: Bool) {
        playerView.player = player
        addObserver(
            self,
            forKeyPath: #keyPath(AVFoundationDrmViewController.player.rate),
            options: [.new, .initial],
            context: &AVFoundationDrmViewController.playerViewControllerKVOContext
        )
        analyticsCollector.attachPlayer(player: player)
        loadDrmSource()
    }

    func loadDrmSource() {
        let fpsConfig = FairPlayConfiguration(licenseUrl: drmLicenseUrl!, certificateUrl: drmCertificateUrl!)
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

        self.asset = Asset(urlAsset: AVURLAsset(url: drmStreamUrl!), fpsConfig: fpsConfig)

        let playerItem = AVPlayerItem(asset: asset!.urlAsset)
        player.replaceCurrentItem(with: playerItem)
        player.play()

        addObserver(
            self,
            forKeyPath: #keyPath(AVFoundationDrmViewController.player.currentItem.duration),
            options: [.new, .initial],
            context: &AVFoundationDrmViewController.playerViewControllerKVOContext
        )

        let interval = CMTimeMake(value: 1, timescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let view = self else {
                return
            }
            let position = Float(CMTimeGetSeconds(time))
            view.slider.value = Float(position)
            view.position.text = view.createTimeString(time: position)
        }
    }

    @IBAction func reloadPlayer() {
        analyticsCollector.detachPlayer()
        loadDrmSource()
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData1_2"
        config.customData2 = "customData2_2"
        config.customData3 = "customData3_2"
        config.customData4 = "customData4_2"
        config.customData5 = "customData5_2"
        config.customerUserId = "customUserId_2"
        config.experimentName = "experiment-12"
        config.videoId = "iOSHLSStatic2"
        config.title = "ios static with AVFoundation"
        config.path = "/vod/breadcrumb/2/"
        config.isLive = true
        analyticsCollector.attachPlayer(player: player)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard context == &AVFoundationDrmViewController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(AVFoundationDrmViewController.player.currentItem.duration) {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            } else {
                newDuration = CMTime.zero
            }

            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0

            slider.maximumValue = Float(newDurationSeconds)

            if !isSeeking {
                slider.value = currentTime
            }

            rewindButton.isEnabled = hasValidDuration
            playButton.isEnabled = hasValidDuration
            fastForwardButton.isEnabled = hasValidDuration
            slider.isEnabled = hasValidDuration
            position.isEnabled = hasValidDuration

            position.text = createTimeString(time: currentTime)

            endDuration.isEnabled = hasValidDuration
            endDuration.text = createTimeString(time: Float(newDurationSeconds))
        } else if keyPath == #keyPath(AVFoundationDrmViewController.player.rate) {
            // Update `playPauseButton` image.
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            let buttonImageName = newRate > 0.0 ? "PauseButton" : "PlayButton"
            let buttonImage = UIImage(named: buttonImageName)

            playButton.setImage(buttonImage, for: UIControl.State())
        }
    }

    // MARK: - IBActions

    @IBAction func playPauseButtonWasPressed(_: UIButton) {
        if player.rate != 1.0 {
            player.play()
        } else {
            // Playing, so pause.
            player.pause()
        }
    }

    @IBAction func jumpForwardButtomPressed(_: UIButton) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, preferredTimescale: 30)
        player.seek(to: CMTimeAdd(currentTime, deltaTime)) { completed in
            if completed {
            }
        }
    }

    @IBAction func backButtonPressed(_: UIButton) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, preferredTimescale: 30)
        player.seek(to: CMTimeSubtract(currentTime, deltaTime)) { completed in
            if completed {
            }
        }
    }

    @IBAction func rewindButtonWasPressed(_: UIButton) {
        // Rewind no faster than -2.0.

        player.rate = max(player.rate - 2.0, -2.0)
    }

    @IBAction func fastForwardButtonWasPressed(_: UIButton) {
        // Fast forward no faster than 2.0.
        player.rate = min(player.rate + 2.0, 2.0)
    }

    @IBAction func timeSliderDidChange(_: UISlider) {
        isSeeking = true
        player.seek(to: CMTimeMakeWithSeconds(Float64(slider.value), preferredTimescale: 30)) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helper

    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }

    /*
     A formatter for individual date components used to provide an appropriate
     value for the `startTimeLabel` and `durationLabel`.
     */
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]

        return formatter
    }()

    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }

    deinit {
        /// Remove any KVO observer.
        playerObserver?.invalidate()
    }
}
