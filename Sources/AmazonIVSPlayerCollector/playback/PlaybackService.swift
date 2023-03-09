#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class PlaybackService {
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
        if state == IVSPlayer.State.idle {
            stateMachine.pause(time: playerContext.position)
        } else if state == IVSPlayer.State.ended {
            stateMachine.pause(time: playerContext.position)
        } else if state == IVSPlayer.State.playing {
            stateMachine.playing(time: playerContext.position)
        }
    }

    func onBuffering() {
        stateMachine.transitionState(destinationState: .buffering, time: playerContext.position)
    }

    func onSeekCompleted(time: CMTime) {
        if playerContext.isLive {
            return
        }

        let currentState = stateMachine.state
        stateMachine.seek(time: time)
        stateMachine.transitionState(destinationState: currentState, time: time)
    }
}
