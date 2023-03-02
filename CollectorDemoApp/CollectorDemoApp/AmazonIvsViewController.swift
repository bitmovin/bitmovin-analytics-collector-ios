import AmazonIVSPlayer
import Foundation
import UIKit
import CoreCollector
import AmazonIVSPlayerCollector

class AmazonIvsViewController: UIViewController, IVSPlayer.Delegate {
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        setupPlayer()
        setupPlayerController()
        connectPlayerController()
        createConfig()
        attachCollector()
        loadVideo(url: URL(string: VideoAssets.ivsLive1080p)!)
    }

    @objc
    func applicationDidEnterBackground(_ notification: NSNotification) {
        playerView?.player?.pause()
    }

    // MARK: - Bitmovin Analytics

    private var collector: AmazonIVSCollector? = nil
    private func createConfig() {
        // create config
        let config = BitmovinAnalyticsConfig(key: AppConfig.analyticsLicenseKey)
        // create adapter
        self.collector = AmazonIVSCollector(config: config)

    }

    private func attachCollector() {
        // attach adapter
        guard let player = player else {
            return
        }

        player.delegate = self
        collector?.attachPlayer(player: player)
    }

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        print("Yeah we also got it")
    }

    // MARK: - Amazon player

    private var player: IVSPlayer?
    private var playerController: IVSPlayerController?

    private func setupPlayerController() {
        playerController = IVSPlayerController(
            playButton: playButton,
            seekSlider: seekSlider,
            bufferIndicator: bufferIndicator
        )
    }
    private func connectPlayerController() {
        guard let player = player else {
            return
        }

        playerController?.attachPlayer(player: player)
    }

    private func setupPlayer() {
        let player = IVSPlayer()
        player.muted = true
        self.player = player
        playerView.player = player
    }

    // autoplay just start the playback imediatelly after loading url
    func loadVideo(url videoURL: URL, autoplay: Bool = false) {
        guard let player = self.player else {
            return
        }

        player.load(videoURL)
        if autoplay {
            player.play()
        }
    }

    // MARK: - View components
    @IBOutlet var playerView: IVSPlayerView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var seekSlider: UISlider!
    @IBOutlet var bufferIndicator: UIActivityIndicatorView!

    @IBAction func doneButtonWasPressed(_: UIButton) {
        playerController?.release()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func releaseButtonWasPressed(_: UIButton) {
        playerController?.detachPlayer()
        playerView.player = nil
        player?.pause()
        player = nil
    }

    @IBAction func createButtonWasPressed(_: UIButton) {
        setupPlayer()
        connectPlayerController()
        attachCollector()
        loadVideo(url: URL(string: VideoAssets.redbull)!)
    }
}
