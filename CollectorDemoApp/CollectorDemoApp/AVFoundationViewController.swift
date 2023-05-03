import AVKit
import CoreCollector
import AVFoundationCollector
import UIKit

class AVFoundationViewController: UIViewController {
    private let logger = _AnalyticsLogger(className: "AVFoundationViewController")
    private static var playerViewControllerKVOContext = 0
    private var analyticsCollector: AVPlayerCollector
    private var isSeeking = false
    private var timeObserverToken: Any?
    private var config: BitmovinAnalyticsConfig
    @objc private var player: AVPlayer? = AVPlayer()

    @IBOutlet var playButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var endDuration: UILabel!
    @IBOutlet var position: UILabel!
    @IBOutlet var fastForwardButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var sourceChangeButton: UIButton!
    @IBOutlet var setCustomDataButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var playerView: PlayerView!
    let url = URL(string: VideoAssets.sintel)
    let corruptedUrl = URL(string: VideoAssets.corruptRedBull)

    var duration: Double {
        guard let currentItem = player?.currentItem else { return 0.0 }
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
        config.videoId = "iOSHLSStatic"
        config.title = "Static HLS Video on iOS"
        config.path = "/vod/breadcrumb/"
        config.isLive = true

        analyticsCollector = AVPlayerCollector(config: config)
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_: Bool) {
        guard let player = player else {
            return
        }

        initPlayerWithCollectorAndPlay(player: player)
    }

    @IBAction func setupPlayerObserver() {
        guard let player = player else {
            return
        }

        addObserver(self, forKeyPath: #keyPath(AVFoundationViewController.player.rate), options: [.new, .initial], context: &AVFoundationViewController.playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(AVFoundationViewController.player.currentItem.duration), options: [.new, .initial], context: &AVFoundationViewController.playerViewControllerKVOContext)
        let interval = CMTimeMake(value: 1, timescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            if let this = self {
                let position = Float(CMTimeGetSeconds(time))
                this.slider.value = Float(position)
                this.position.text = this.createTimeString(time: position)
            }
        }
    }

    @IBAction func reloadPlayer() {
        guard let player = player else {
            return
        }

        analyticsCollector.detachPlayer()
        player.pause()
        let asset = AVURLAsset(url: url!, options: nil)
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))

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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AVFoundationViewController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        guard let player = player else {
            return
        }

        if keyPath == #keyPath(AVPlayerViewController.player.currentItem.duration) {
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
        } else if keyPath == #keyPath(AVFoundationViewController.player.rate) {
            // Update `playPauseButton` image.
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            let buttonImageName = newRate > 0.0 ? "PauseButton" : "PlayButton"
            let buttonImage = UIImage(named: buttonImageName)

            playButton.setImage(buttonImage, for: UIControl.State())
        }
    }

    // MARK: - IBActions

    @IBAction func sourceChangeButtonWasPressed(_: UIButton) {
        reloadPlayer()
    }

    @IBAction func playPauseButtonWasPressed(_: UIButton) {
        guard let player = player else {
            return
        }

        if player.rate != 1.0 {
            player.play()
        } else {
            // Playing, so pause.
            player.pause()
        }
    }

    @IBAction func jumpForwardButtomPressed(_: UIButton) {
        guard let player = player else {
            return
        }

        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, preferredTimescale: 30)
        player.seek(to: CMTimeAdd(currentTime, deltaTime), completionHandler: { completed in
            if completed {
            }
        })
    }

    @IBAction func backButtonPressed(_: UIButton) {
        guard let player = player else {
            return
        }

        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, preferredTimescale: 30)
        player.seek(to: CMTimeSubtract(currentTime, deltaTime), completionHandler: { completed in
            if completed {
            }
        })
    }

    @IBAction func rewindButtonWasPressed(_: UIButton) {
        // Rewind no faster than -2.0.
        guard let player = player else {
            return
        }

        player.rate = max(player.rate - 2.0, -2.0)
    }

    @IBAction func fastForwardButtonWasPressed(_: UIButton) {
        // Fast forward no faster than 2.0.
        guard let player = player else {
            return
        }

        player.rate = min(player.rate + 2.0, 2.0)
    }

    @IBAction func timeSliderDidChange(_: UISlider) {
        guard let player = player else {
            return
        }

        isSeeking = true
        player.seek(to: CMTimeMakeWithSeconds(Float64(slider.value), preferredTimescale: 30)) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    @IBAction func setCustomDataButtonWasPressed(_: UIButton) {
        let currentCustomData = analyticsCollector.getCustomData()
        currentCustomData.customData1 = "some test"
        currentCustomData.customData2 = "other test"
        analyticsCollector.setCustomDataOnce(customData: currentCustomData)
    }

    @IBAction func doneButtonWasPressed(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func releaseButtonWasPressed(_: UIButton) {
        analyticsCollector.detachPlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    @IBAction func createButtonWasPressed(_: UIButton) {
        if player != nil {
            return
        }

        player = AVPlayer()

        guard let player = player else {
            return
        }

        initPlayerWithCollectorAndPlay(player: player)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }

    private func initPlayerWithCollectorAndPlay(player: AVPlayer){
        player.isMuted = true
        playerView.playerLayer.player = player
        setupPlayerObserver()

        logger.d("------- attach analytics")
        analyticsCollector.attachPlayer(player: player)

        logger.d("------- set item")
        let asset = AVURLAsset(url: url!, options: nil)
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))

        logger.d("------- player play")
        player.play()
    }
}
