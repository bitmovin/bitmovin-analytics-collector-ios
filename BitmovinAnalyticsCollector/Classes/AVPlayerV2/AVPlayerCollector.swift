import AVKit
import Foundation
#if SWIFT_PACKAGE
import CoreCollector
#endif

public class AVPlayerCollector: Collector {
    public typealias TPlayer = AVPlayer

    private var analytics: BitmovinAnalyticsInternal

    @objc public init(config: BitmovinAnalyticsConfig) {
        self.analytics = BitmovinAnalyticsInternal.createAnalytics(config: config)
    }

    /**
     * Attach a player instance to this analytics plugin. After this is completed, BitmovinAnalytics
     * will start monitoring and sending analytics data based on the attached player instance.
     */
    @objc public func attachPlayer(player: AVPlayer) {
        let errorHandler = ErrorHandler()
        let bitrateDetectionService = BitrateDetectionService()
        let downloadSpeedMeter = DownloadSpeedMeter()
        let downloadSpeedDetectionService = DownloadSpeedDetectionService(downloadSpeedMeter: downloadSpeedMeter)
        let playbackTypeDetectionService = PlaybackTypeDetectionService(player: player)
        let manipulator = AVPlayerEventDataManipulator(player: player, playbackTypeDetectionService: playbackTypeDetectionService, downloadSpeedMeter: downloadSpeedMeter)
        
        let adapter = AVPlayerAdapter(player: player,
                                      stateMachine: analytics.stateMachine,
                                      errorHandler: errorHandler,
                                      bitrateDetectionService: bitrateDetectionService,
                                      playbackTypeDetectionService: playbackTypeDetectionService,
                                      downloadSpeedDetectionService: downloadSpeedDetectionService,
                                      downloadSpeedMeter: downloadSpeedMeter,
                                      manipulator: manipulator
        )
        analytics.attach(adapter: adapter)
    }

    @objc public func detachPlayer() {
        analytics.detachPlayer()
    }

    @objc public func getCustomData() -> CustomData {
        return analytics.getCustomData()
    }

    @objc public func setCustomData(customData: CustomData) {
        return analytics.setCustomData(customData: customData)
    }

    @objc public func setCustomDataOnce(customData: CustomData) {
        return analytics.setCustomDataOnce(customData: customData)
    }
    
    @objc public func getUserId() -> String {
        return analytics.getUserId()
    }
}
