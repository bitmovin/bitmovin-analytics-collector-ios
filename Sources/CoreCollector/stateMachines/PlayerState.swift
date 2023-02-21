import Foundation

public enum PlayerState: String {
    case ad
    case adFinished
    case ready
    case startup
    case buffering
    case error
    case playing
    case paused
    case qualitychange
    case seeking
    case subtitlechange
    // TODO can be removed - both video and audio changes handled by `qualityChange` state
    case audiochange
    case playAttemptFailed
    case sourceChanged
    case customdatachange

    func onEntry(stateMachine: StateMachine) {
        switch self {
        case .ad:
            return
        case .adFinished:
            return
        case .ready:
            return
        case .startup:
            stateMachine.videoStartFailureService.startTimer()
            return
        case .buffering:
            stateMachine.rebufferingHeartbeatService.startHeartbeat()
            return
        case .playAttemptFailed:
            return
        case .error:
            stateMachine.delegate?.stateMachineDidEnterError(stateMachine)
            return
        case .paused:
            return
        case .playing:
            stateMachine.enableHeartbeat()
            return
        case .qualitychange:
            stateMachine.qualityChangeCounter.increaseCounter()
            return
        case .seeking:
            return
        case .subtitlechange:
            return
        case .audiochange:
            return
        case .sourceChanged:
            return
        case .customdatachange:
            return
        }
    }

    func onExit(stateMachine: StateMachine, duration: Int64, destinationState: PlayerState) {
        if destinationState == .playAttemptFailed {
            stateMachine.rebufferingHeartbeatService.disableHeartbeat()
            stateMachine.delegate?.stateMachineEnterPlayAttemptFailed(stateMachine: stateMachine)
            return
        }

        switch self {
        case .ad:
            stateMachine.delegate?.stateMachine(stateMachine, didAdWithDuration: duration)
            return
        case .adFinished:
            return
        case .ready:
            return
        case .startup:
            stateMachine.videoStartFailureService.clearTimer()
            stateMachine.startupTime += duration
            if destinationState == .playing {
                stateMachine.setDidStartPlayingVideo()
                stateMachine.delegate?.stateMachine(stateMachine, didStartupWithDuration: stateMachine.startupTime)
            }
        case .buffering:
            stateMachine.rebufferingHeartbeatService.disableHeartbeat()
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
            if stateMachine.qualityChangeCounter.isQualityChangeEnabled {
                   stateMachine.delegate?.stateMachineDidQualityChange(stateMachine)
            } else {
                stateMachine.setErrorData(error: ErrorData.QUALITY_CHANGE_THRESHOLD_EXCEEDED)
                stateMachine.delegate?.stateMachineDidEnterError(stateMachine)
            }
            return
        case .seeking:
            stateMachine.delegate?.stateMachine(
                stateMachine,
                didExitSeekingWithDuration: duration,
                destinationPlayerState: destinationState
            )
            return
        case .subtitlechange:
            stateMachine.delegate?.stateMachineDidSubtitleChange(stateMachine)
            return
        // TODO can be removed
        case .audiochange:
            stateMachine.delegate?.stateMachineDidAudioChange(stateMachine)
            return
        case .sourceChanged:
            return
        case .customdatachange:
            return
        }
    }
}
