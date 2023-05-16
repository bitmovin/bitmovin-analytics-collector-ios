import AVFoundation
import Foundation

#if SWIFT_PACKAGE
import CoreCollector
#endif

internal enum AVPlayerAdapterFactory {
    static func createAdapter(
        analytics: BitmovinAnalyticsInternal,
        eventDataFactory: EventDataFactory,
        player: AVPlayer
    ) -> AVPlayerAdapter {
        let errorHandler = ErrorHandler()
        let bitrateDetectionService = BitrateDetectionService()
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        let playbackTypeDetectionService = PlaybackTypeDetectionService(player: player)
        let manipulator = AVPlayerEventDataManipulator(
            player: player,
            playbackTypeDetectionService: playbackTypeDetectionService,
            downloadSpeedMeter: downloadSpeedMeter
        )
        eventDataFactory.registerEventDataManipulator(manipulator: manipulator)

        let playerContext = AVPlayerContext(player: player, playbackTypeDetectionService: playbackTypeDetectionService)
        let stateMachine = StateMachineFactory.create(playerContext: playerContext)
        analytics.setStateMachine(stateMachine)
        return AVPlayerAdapter(
            player: player,
            stateMachine: stateMachine,
            errorHandler: errorHandler,
            bitrateDetectionService: bitrateDetectionService,
            playbackTypeDetectionService: playbackTypeDetectionService,
            downloadSpeedDetectionService: downloadSpeedDetectionService,
            downloadSpeedMeter: downloadSpeedMeter,
            manipulator: manipulator
        )
    }
}
