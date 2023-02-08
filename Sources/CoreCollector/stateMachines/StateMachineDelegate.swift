import CoreMedia
import Foundation

protocol StateMachineDelegate: AnyObject {
    func stateMachineDidExitSetup(_ stateMachine: StateMachine)
    func stateMachineEnterPlayAttemptFailed(stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitBufferingWithDuration duration: Int64)
    func stateMachineDidEnterError(_ stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitPlayingWithDuration duration: Int64)
    func stateMachine(_ stateMachine: StateMachine, didExitPauseWithDuration duration: Int64)
    func stateMachineDidQualityChange(_ stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitSeekingWithDuration duration: Int64, destinationPlayerState: PlayerState)
    func stateMachine(_ stateMachine: StateMachine, didHeartbeatWithDuration duration: Int64)
    func stateMachine(_ stateMachine: StateMachine, didStartupWithDuration duration: Int64)
    func stateMachine(_ stateMachine: StateMachine, didAdWithDuration duration: Int64)
    func stateMachineDidSubtitleChange(_ stateMachine: StateMachine)
    func stateMachineDidAudioChange(_ stateMachine: StateMachine)
    func stateMachineResetSourceState()
    func stateMachineStopsCollecting()
    var currentTime: CMTime? { get }
}
