import AmazonIVSPlayer
import CoreCollector

class AmazonIVSPlayerListener: NSObject, IVSPlayer.Delegate {
    private weak var player: IVSPlayerProtocol?
    private weak var customerDelegate: IVSPlayer.Delegate?
    private let videoStartupService: VideoStartupService
    private let playbackService: PlaybackService
    private let errorService: ErrorService
    private let stateMachine: StateMachine

    init(
        player: IVSPlayerProtocol,
        videoStartupService: VideoStartupService,
        stateMachine: StateMachine,
        playbackService: PlaybackService,
        errorService: ErrorService
    ) {
        self.player = player
        self.videoStartupService = videoStartupService
        self.playbackService = playbackService
        self.errorService = errorService
        self.stateMachine = stateMachine
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
        playbackService.onQualityChange(quality)
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
        guard let player = player else {
            return
        }

        customerDelegate = player.delegate
        player.delegate = self
        videoStartupService.shouldStartup(state: player.state)
    }

    func stopMonitoring() {
        if let player = self.player {
            player.delegate = customerDelegate
        }

        customerDelegate = nil
    }
}
