
import Foundation

protocol StateMachineDelegate: class {
    func stateMachineDidExitSetup(_ stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitBufferingWithDuration duration: Int)
    func stateMachineDidEnterError(_ stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitPlayingWithDuration duration: Int)
    func stateMachine(_ stateMachine: StateMachine, didExitPauseWithDuration duration: Int)
    func stateMachineDidQualityChange(_ stateMachine: StateMachine)
    func stateMachine(_ stateMachine: StateMachine, didExitSeekingWithDuration duration: Int, destinationPlayerState: PlayerState)
    func stateMachine(_ stateMachine: StateMachine, didHeartbeatWithDuration duration: Int)
    func stateMachine(_ stateMachine: StateMachine, didStartupWithDuration duration: Int)
}
