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
            stateMachine.listener?.onError(stateMachine)
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
            stateMachine.listener?.onVideoStartFailed(stateMachine)
            return
        }

        switch self {
        case .ad:
            stateMachine.listener?.onAdFinished(withDuration: duration)
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
                stateMachine.listener?.onStartup(withDuration: stateMachine.startupTime)
            }
        case .buffering:
            stateMachine.rebufferingHeartbeatService.disableHeartbeat()
            stateMachine.listener?.onRebuffering(withDuration: duration)
            return
        case .playAttemptFailed:
            return
        case .error:
            return
        case .playing:
            stateMachine.listener?.onPlayingExit(withDuration: duration)
            stateMachine.disableHeartbeat()
            return
        case .paused:
            stateMachine.listener?.onPauseExit(withDuration: duration)
            return
        case .qualitychange:
            if stateMachine.qualityChangeCounter.isQualityChangeEnabled {
                   stateMachine.listener?.onVideoQualityChanged()
            } else {
                stateMachine.setErrorData(error: ErrorData.QUALITY_CHANGE_THRESHOLD_EXCEEDED)
                stateMachine.listener?.onError(stateMachine)
            }
            return
        case .seeking:
            stateMachine.listener?.onSeekComplete(withDuration: duration)
            return
        case .subtitlechange:
            stateMachine.listener?.onSubtitleChanged()
            return
        // TODO can be removed
        case .audiochange:
            stateMachine.listener?.onAudioQualityChanged()
            return
        case .sourceChanged:
            return
        case .customdatachange:
            return
        }
    }
}
