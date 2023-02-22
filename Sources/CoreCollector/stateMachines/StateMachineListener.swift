import CoreMedia
import Foundation

protocol StateMachineListener: AnyObject {
    func onStartup(withDuration duration: Int64)
    func onPauseExit(withDuration duration: Int64)
    func onPlayingExit(withDuration duration: Int64)
    func onHeartbeat(withDuration duration: Int64, state: PlayerState)
    func onRebuffering(withDuration duration: Int64)
    func onSeekComplete(withDuration duration: Int64)
    func onAdFinished(withDuration duration: Int64)

    // Error events
    // Here we still need to pass the stateMachine because of the interface getError
    func onError(_ stateMachine: StateMachine)
    func onVideoStartFailed(_ stateMachine: StateMachine)

    func onVideoQualityChanged()
    func onAudioQualityChanged()
    func onSubtitleChanged()

    // Maybe we can rethink these methods here
    func stateMachineResetSourceState()
    func stateMachineStopsCollecting()

    // TODO use PositionProvider instead
    var currentTime: CMTime? { get }
}
