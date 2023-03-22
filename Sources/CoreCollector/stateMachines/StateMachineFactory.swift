public class StateMachineFactory {
    public static func create(playerContext: PlayerContext) -> StateMachine {
        DefaultStateMachine(playerContext: playerContext)
    }
}
