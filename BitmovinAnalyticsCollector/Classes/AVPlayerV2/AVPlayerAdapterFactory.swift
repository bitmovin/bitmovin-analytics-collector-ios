import Foundation
import AVFoundation

#if SWIFT_PACKAGE
@testable import CoreCollector
#endif

class AVPlayerAdapterFactory {
    func createAdapter(stateMachine: StateMachine, player: AVPlayer) -> AVPlayerAdapter {
        let errorHandler = ErrorHandler()
        let bitrateDetectionService = BitrateDetectionService()
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        let playbackTypeDetectionService = PlaybackTypeDetectionService(player: player)
        let manipulator = AVPlayerEventDataManipulator(player: player, playbackTypeDetectionService: playbackTypeDetectionService, downloadSpeedMeter: downloadSpeedMeter)
        
        return AVPlayerAdapter(player: player,
                               stateMachine: stateMachine,
                               errorHandler: errorHandler,
                               bitrateDetectionService: bitrateDetectionService,
                               playbackTypeDetectionService: playbackTypeDetectionService,
                               downloadSpeedDetectionService: downloadSpeedDetectionService,
                               downloadSpeedMeter: downloadSpeedMeter,
                               manipulator: manipulator)
    }
}
