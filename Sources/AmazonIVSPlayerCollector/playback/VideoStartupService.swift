#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class VideoStartupService {
    private let playerContext: AmazonIVSPlayerContext
    private let stateMachine: StateMachine

    init(
        playerContext: AmazonIVSPlayerContext,
        stateMachine: StateMachine
    ) {
        self.playerContext = playerContext
        self.stateMachine = stateMachine
    }

    func onStateChange(state: IVSPlayer.State) {
        if state == IVSPlayer.State.buffering {
            stateMachine.play(time: nil)
        } else if state == IVSPlayer.State.playing {
            stateMachine.playing(time: playerContext.position)
        }
    }

    func shouldStartup(state: IVSPlayer.State) {
        guard !stateMachine.didStartPlayingVideo else {
            return
        }

        let shouldStartup =
            state == IVSPlayer.State.playing ||
            state == IVSPlayer.State.buffering

        let isPlaying = state == IVSPlayer.State.playing

        if shouldStartup {
            stateMachine.play(time: nil)
        }

        if isPlaying {
            stateMachine.playing(time: playerContext.position)
        }
    }
}
