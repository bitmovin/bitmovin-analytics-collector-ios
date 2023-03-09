#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class ErrorService {
    private let playerContext: PlayerContext
    private let stateMachine: StateMachine

    init(
        playerContext: PlayerContext,
        stateMachine: StateMachine
    ) {
        self.playerContext = playerContext
        self.stateMachine = stateMachine
    }

    func onError(error: Error) {
        // it should be possible to always convert NSError <> Error
        let err = error as NSError

        let errorData = ErrorData(
            code: err.code,
            message: err.localizedDescription,
            data: err.localizedFailureReason
        )

        if !stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.playerError, withError: errorData)
        } else {
            stateMachine.error(withError: errorData, time: playerContext.position)
        }
    }
}
