import Foundation

public enum PlayerState: String {
    case ready
    case startup
    case buffering
    case error
    case playing
    case paused
    case qualitychange
    case seeking
    case subtitlechange
    case audiochange
    case playAttemptFailed

    func onEntry(stateMachine: StateMachine, timestamp _: Int64, previousState : PlayerState, data: [AnyHashable: Any]?) {
        switch self {
        case .ready:
            return
        case .startup:
            return
        case .buffering:
            stateMachine.enableRebufferHeartbeat()
            return
        case .playAttemptFailed:
            return
        case .error:
            stateMachine.delegate?.stateMachineDidEnterError(stateMachine, data: data)
            return
        case .paused:
            return
        case .playing:
            stateMachine.enableHeartbeat()
            return
        case .qualitychange:
            return
        case .seeking:
            return
        case .subtitlechange:
            return
        case .audiochange:
            return
        }
    }

    func onExit(stateMachine: StateMachine, timestamp: Int64, destinationState: PlayerState) {
        // Get the duration we were in the state we are exiting
        let enterTimestamp = stateMachine.enterTimestamp ?? 0
        let duration = timestamp - enterTimestamp
        if (destinationState == .playAttemptFailed) {
            stateMachine.disableRebufferHeartbeat()
            stateMachine.delegate?.stateMachineEnterPlayAttemptFailed(stateMachine: stateMachine)
            return
        }
        
        switch self {
        case .ready:
            return
        case .startup:
            stateMachine.startupTime += duration
            if(destinationState == .playing) {
                stateMachine.didStartPlayingVideo = true
                stateMachine.delegate?.stateMachine(stateMachine, didStartupWithDuration: stateMachine.startupTime)
            }
        case .buffering:
            stateMachine.disableRebufferHeartbeat()
            stateMachine.delegate?.stateMachine(stateMachine, didExitBufferingWithDuration: duration)
            return
        case .playAttemptFailed:
            return
        case .error:
            return
        case .playing:
            stateMachine.delegate?.stateMachine(stateMachine, didExitPlayingWithDuration: duration)
            stateMachine.disableHeartbeat()
            return
        case .paused:
            stateMachine.delegate?.stateMachine(stateMachine, didExitPauseWithDuration: duration)
            return
        case .qualitychange:
            stateMachine.delegate?.stateMachineDidQualityChange(stateMachine)
            return
        case .seeking:
            stateMachine.delegate?.stateMachine(stateMachine, didExitSeekingWithDuration: duration, destinationPlayerState: destinationState)
            return
        case .subtitlechange:
            stateMachine.delegate?.stateMachineDidSubtitleChange(stateMachine)
            return
        case .audiochange:
            stateMachine.delegate?.stateMachineDidAudioChange(stateMachine)
            return
        }
    }
}
