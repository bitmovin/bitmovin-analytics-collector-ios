#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class DefaultVideoStartupService: VideoStartupService {
    private let playerContext: PlayerContext
    private let stateMachine: StateMachine

    init(
        playerContext: PlayerContext,
        stateMachine: StateMachine
    ) {
        self.playerContext = playerContext
        self.stateMachine = stateMachine
    }

    func onStateChange(state: IVSPlayer.State) {
        if state == IVSPlayer.State.buffering {
            stateMachine.play(time: nil)
        } else if state == IVSPlayer.State.playing {
            // for VOD videos with autoplay, buffering is not triggered
            // and we don't have a way to detect intention to play
            shouldStartup(state: state)
        }
    }

    func shouldStartup(state: IVSPlayer.State) {
        if stateMachine.didStartPlayingVideo {
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
