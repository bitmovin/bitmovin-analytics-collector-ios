import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

class AmazonIVSPlayerListener: NSObject, IVSPlayer.Delegate {
    private let player: IVSPlayer
    private weak var customerDelegate: IVSPlayer.Delegate?
    private let videoStartupService: VideoStartupService
    private let playbackService: PlaybackService
    private let errorService: ErrorService
    private let stateMachine: StateMachine
    private let qualityProvider: PlaybackQualityProvider

    init(
        player: IVSPlayer,
        videoStartupService: VideoStartupService,
        stateMachine: StateMachine,
        playbackService: PlaybackService,
        errorService: ErrorService,
        qualityProvider: PlaybackQualityProvider
    ) {
        self.player = player
        self.videoStartupService = videoStartupService
        self.playbackService = playbackService
        self.errorService = errorService
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
        self.customerDelegate?.player?(player, didChangeQuality: quality)
    }

    func playerWillRebuffer(_ player: IVSPlayer) {
        playbackService.onBuffering()
        self.customerDelegate?.playerWillRebuffer?(player)
    }

    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        errorService.onError(error: error)
        self.customerDelegate?.player?(player, didFailWithError: error)
    }

    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        self.customerDelegate?.player?(player, didChangeDuration: duration)
    }

    func playerNetworkDidBecomeUnavailable(_ player: IVSPlayer) {
        self.customerDelegate?.playerNetworkDidBecomeUnavailable?(player)
    }

    func player(_ player: IVSPlayer, didSeekTo time: CMTime) {
        playbackService.onSeekCompleted(time: time)
        self.customerDelegate?.player?(player, didSeekTo: time)
    }

    func player(_ player: IVSPlayer, didOutputCue cue: IVSCue) {
        self.customerDelegate?.player?(player, didOutputCue: cue)
    }

    func player(_ player: IVSPlayer, didChangeVideoSize videoSize: CGSize) {
        self.customerDelegate?.player?(player, didChangeVideoSize: videoSize)
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
