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
    init(
        player: IVSPlayer,
        videoStartupService: VideoStartupService,
        playbackService: PlaybackService,
        stateMachine: StateMachine
    ) {
        self.player = player
        self.videoStartupService = videoStartupService
        self.playbackService = playbackService
        self.stateMachine = stateMachine
    }

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        print("We got and player state change \(state)")
        if !stateMachine.didStartPlayingVideo {
            videoStartupService.onStateChange(state: state)
        } else {
            playbackService.onStateChange(state: state)
        }
        self.customerDelegate?.player?(player, didChangeState: state)
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
