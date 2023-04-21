#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class DefaultPlaybackService: PlaybackService {
    private let playerContext: PlayerContext
    private let stateMachine: StateMachine
    private var qualityProvider: PlaybackQualityProvider
    private let statisticsProvider: PlayerStatisticsProvider

    init(
        playerContext: PlayerContext,
        stateMachine: StateMachine,
        qualityProvider: PlaybackQualityProvider,
        statisticsProvider: PlayerStatisticsProvider
    ) {
        self.playerContext = playerContext
        self.stateMachine = stateMachine
        self.qualityProvider = qualityProvider
        self.statisticsProvider = statisticsProvider
    }

    func onStateChange(state: IVSPlayer.State) {
        if state == IVSPlayer.State.idle {
            stateMachine.pause(time: playerContext.position)
        } else if state == IVSPlayer.State.ended {
            stateMachine.pause(time: playerContext.position)
        } else if state == IVSPlayer.State.playing {
            stateMachine.playing(time: playerContext.position)
        }
    }

    func onBuffering() {
        stateMachine.transitionState(destinationState: .buffering, time: playerContext.position)
    }

    func onSeekCompleted(time: CMTime) {
        let seekEnabled = playerContext.isLive == false
        if !seekEnabled {
            return
        }

        let currentState = stateMachine.state
        stateMachine.seek(time: time)
        stateMachine.transitionState(destinationState: currentState, time: time)
    }

    func onQualityChange(_ quality: IVSQualityProtocol?) {
        //initial quality change will not trigger state change
        if qualityProvider.currentQuality == nil {
            qualityProvider.currentQuality = quality
            return
        }

        guard qualityProvider.didQualityChange(newQuality: quality) else {
            return
        }

        stateMachine.videoQualityChange(time: playerContext.position) { [weak qualityProvider = self.qualityProvider] in
            qualityProvider?.currentQuality = quality
        }

        // according to IVS support droppedFrames are set to 0 on a quality
        // change event, thus we also need to reset our internal counter to compute
        // the correct droppedFrames per sample
        // this might be subject to change in the future according to IVS
        self.statisticsProvider.reset()
    }
}
