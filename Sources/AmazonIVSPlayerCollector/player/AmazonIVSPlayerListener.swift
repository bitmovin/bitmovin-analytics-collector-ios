import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AmazonIVSPlayerListener: NSObject, IVSPlayer.Delegate {
    private let player: IVSPlayer
    private weak var customerDelegate: IVSPlayer.Delegate?
    private let videoStartupService: VideoStartupService
    private let playbackService: PlaybackService
    private let stateMachine: StateMachine
    private let qualityProvider: PlaybackQualityProvider

    init(
        player: IVSPlayer,
        videoStartupService: VideoStartupService,
        stateMachine: StateMachine,
        playbackService: PlaybackService,
        qualityProvider: PlaybackQualityProvider
    ) {
        self.player = player
        self.videoStartupService = videoStartupService
        self.playbackService = playbackService
        self.stateMachine = stateMachine
        self.qualityProvider = qualityProvider
    }

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        if !stateMachine.didStartPlayingVideo {
            videoStartupService.onStateChange(state: state)
        } else {
            playbackService.onStateChange(state: state)
        }
        self.customerDelegate?.player?(player, didChangeState: state)
    }

    func player(_ player: IVSPlayer, didChangeQuality quality: IVSQuality?) {
        guard qualityProvider.didQualityChange(newQuality: quality) else {
            return
        }

        stateMachine.videoQualityChange(time: player.position) { [qualityProvider = self.qualityProvider] in
            qualityProvider.currentQuality = quality
        }
    }

    func playerWillRebuffer(_ player: IVSPlayer) {
        playbackService.onBuferring()
        self.customerDelegate?.playerWillRebuffer?(player)
    }

    func startMonitoring() {
        customerDelegate = player.delegate
        player.delegate = self
        videoStartupService.shouldStartup(state: self.player.state)
    }

    func stopMonitoring() {
        player.delegate = customerDelegate
        customerDelegate = nil
    }
}
