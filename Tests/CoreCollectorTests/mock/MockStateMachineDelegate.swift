import CoreMedia
@testable import CoreCollector

class MockStateMachineDelegate: StateMachineListener {
    func onVideoStartFailed(_ stateMachine: StateMachine) {
    }

    func onRebuffering(withDuration duration: Int64) {
    }

    func onError(_ stateMachine: StateMachine) {
    }

    private var exitPlayingAction: (() -> Void)?
    func setActionForExitPlaying(action: @escaping () -> Void) {
            exitPlayingAction = action
    }

    func onPlayingExit(withDuration duration: Int64) {
        exitPlayingAction?()
    }

    func onPauseExit(withDuration duration: Int64) {
    }

    func onVideoQualityChanged() {
    }

    func onSeekComplete(withDuration duration: Int64) {
    }

    func onHeartbeat(withDuration duration: Int64, state: PlayerState) {
    }

    func onStartup(withDuration duration: Int64) {
    }

    func onSubtitleChanged() {
    }

    func onAudioQualityChanged() {
    }

    func onAdFinished(withDuration duration: Int64) {
    }

    func stateMachineResetSourceState() {
    }

    func stateMachineStopsCollecting() {
    }

    var currentTime: CMTime?
}
