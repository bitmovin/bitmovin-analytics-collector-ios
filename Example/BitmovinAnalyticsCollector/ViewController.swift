import AVKit
import BitmovinAnalyticsCollector
import UIKit

class ViewController: UIViewController {
    private static var playerViewControllerKVOContext = 0
    private var analyticsCollector: BitmovinAnalytics
    private var isSeeking: Bool = false
    private var timeObserverToken: Any?
    private var config: BitmovinAnalyticsConfig
    @objc private let player: AVPlayer = AVPlayer()

    @IBOutlet var playButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var endDuration: UILabel!
    @IBOutlet var position: UILabel!
    @IBOutlet var fastForwardButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var playerView: PlayerView!

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

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: "9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac")
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "iOSHLSStatic"
        config.path = "/vod/breadcrumb/"

        analyticsCollector = BitmovinAnalytics(config: config)
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_: Bool) {
        playerView.playerLayer.player = player
        addObserver(self, forKeyPath: #keyPath(ViewController.player.rate), options: [.new, .initial], context: &ViewController.playerViewControllerKVOContext)
        createPlayer()
        analyticsCollector.attachAVPlayer(player: player)
    }

    @IBAction func createPlayer() {
        addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.duration), options: [.new, .initial], context: &ViewController.playerViewControllerKVOContext)
        let movieURL = URL(string: "http://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
        let asset = AVURLAsset(url: movieURL!, options: nil)
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        player.play()
        let interval = CMTimeMake(1, 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
            let position = Float(CMTimeGetSeconds(time))
            self.slider.value = Float(position)
            self.position.text = self.createTimeString(time: position)
        }
    }

    @IBAction func reloadPlayer() {
        analyticsCollector.detachPlayer()
        createPlayer()
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData6"
        config.customData2 = "customData7"
        config.customData3 = "customData8"
        config.customData4 = "customData9"
        config.customData5 = "customData10"
        config.customerUserId = "customUserId2"
        config.experimentName = "experiment-12"
        config.videoId = "iOSHLSStatic2"
        config.path = "/vod/breadcrumb/2/"
        analyticsCollector.attachAVPlayer(player: player)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &ViewController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(ViewController.player.currentItem.duration) {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            } else {
                newDuration = kCMTimeZero
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
        } else if keyPath == #keyPath(ViewController.player.rate) {
            // Update `playPauseButton` image.
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            let buttonImageName = newRate > 0.0 ? "PauseButton" : "PlayButton"
            let buttonImage = UIImage(named: buttonImageName)

            playButton.setImage(buttonImage, for: UIControlState())
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
        let deltaTime = CMTimeMakeWithSeconds(30, 30)
        player.seek(to: CMTimeAdd(currentTime, deltaTime), completionHandler: { completed in
            if completed {
            }
        })
    }

    @IBAction func backButtonPressed(_: UIButton) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMakeWithSeconds(30, 30)
        player.seek(to: CMTimeSubtract(currentTime, deltaTime), completionHandler: { completed in
            if completed {
            }
        })
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
        player.seek(to: CMTimeMakeWithSeconds(Float64(slider.value), 30)) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
