import CoreCollector
import AmazonIVSPlayer

class DefaultVideoStartupService: VideoStartupService {
    private let playerContext: PlayerContext
    private weak var player: IVSPlayerProtocol?
    private let stateMachine: StateMachine
    private let playbackQualityProvider: PlaybackQualityProvider

    init(
        playerContext: PlayerContext,
        stateMachine: StateMachine,
        player: IVSPlayerProtocol,
        playbackQualityProvider: PlaybackQualityProvider
    ) {
        self.playerContext = playerContext
        self.stateMachine = stateMachine
        self.player = player
        self.playbackQualityProvider = playbackQualityProvider
    }

    func onStateChange(state: IVSPlayer.State) {
        if state == IVSPlayer.State.buffering {
            stateMachine.play(time: nil)
        } else if state == IVSPlayer.State.playing {
            // for VOD videos with autoplay, buffering is not triggered
            // and we don't have a way to detect intention to play
            shouldStartup(state: state)
        }
    }

    func shouldStartup(state: IVSPlayer.State) {
        if stateMachine.didStartPlayingVideo {
            return
        }

        let shouldStartup =
            state == IVSPlayer.State.playing ||
            state == IVSPlayer.State.buffering

        let isPlaying = state == IVSPlayer.State.playing

        if shouldStartup {
            stateMachine.play(time: nil)
        }

        // we set the initial quality during startup, to avoid sending a sample on the first quality change event
        // which is just the initial quality and not a real change
        playbackQualityProvider.currentQuality = player?.qualityProtocol
        if isPlaying {
            stateMachine.playing(time: playerContext.position)
        }
    }
}
