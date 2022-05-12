import Foundation
import AVFoundation
import UIKit

#if SWIFT_PACKAGE
import CoreCollector
#endif

class AVPlayerEventDataManipulator {
    
    private let player: AVPlayer
    
    // event data tracking
    internal var drmDownloadTime: Int64?
    private var drmType: String?
    private(set) var currentVideoQuality: VideoQualityDto?
    
    // Helper classes
    private let playbackTypeDetectionService: PlaybackTypeDetectionService
    private let downloadSpeedDetectionService: DownloadSpeedDetectionService
    
    init(player: AVPlayer, playbackTypeDetectionService: PlaybackTypeDetectionService, downloadSpeedDetectionService: DownloadSpeedDetectionService) {
        self.player = player
        self.playbackTypeDetectionService = playbackTypeDetectionService
        self.downloadSpeedDetectionService = downloadSpeedDetectionService
    }
    
    func resetSourceState() {
        currentVideoQuality = nil
        drmType = nil
        drmDownloadTime = nil
    }
    
    func manipulate(eventData: EventData) {
        // Player
        eventData.player = PlayerType.avplayer.rawValue

        // Player Tech
        eventData.playerTech = "ios:avplayer"

        // Duration
        if let duration = player.currentItem?.duration, CMTIME_IS_NUMERIC(_: duration) {
            eventData.videoDuration = Int64(CMTimeGetSeconds(duration) * BitmovinAnalyticsInternal.msInSec)
        }

        // isCasting
        eventData.isCasting = player.isExternalPlaybackActive

        // DRM Type
        eventData.drmType = self.drmType
        
        // isLive
        if playbackTypeDetectionService.playbackType != nil {
            eventData.isLive = playbackTypeDetectionService.isLive()
        }

        // version
        eventData.version = PlayerType.avplayer.rawValue + "-" + UIDevice.current.systemVersion

        if let urlAsset = (player.currentItem?.asset as? AVURLAsset),
           let streamFormat = Util.streamType(from: urlAsset.url.absoluteString) {
            eventData.streamFormat = streamFormat.rawValue
            switch streamFormat {
            case .dash:
                eventData.mpdUrl = urlAsset.url.absoluteString
                //not possible to get audio bitrate from AVPlayer for adaptive streaming
            case .hls:
                eventData.m3u8Url = urlAsset.url.absoluteString
                //not possible to get audio bitrate from AVPlayer for adaptive streaming
            case .progressive:
                eventData.progUrl = urlAsset.url.absoluteString
                //audio bitrate for progressive streaming
                eventData.audioBitrate = getAudioBitrateFromProgressivePlayerItem(forItem: player.currentItem) ?? 0.0
            case .unknown:
                break
            }
        }

        // video quality
        if let videoQuality = currentVideoQuality {
            eventData.videoBitrate = videoQuality.videoBitrate
            eventData.videoPlaybackWidth = videoQuality.videoWidth
            eventData.videoPlaybackHeight = videoQuality.videoHeight
        }

        // isMuted
        if player.volume == 0 {
            eventData.isMuted = true
        }
        
        setDownloadSpeedInfo(eventData: eventData)
    }
    
    func updateDrmPerformanceInfo(_ playerItem: AVPlayerItem) {
        let asset = playerItem.asset
        asset.loadValuesAsynchronously(forKeys: ["hasProtectedContent"]) { [weak self] in
            guard let adapter = self else {
                return
            }
            var error: NSError?
            if asset.statusOfValue(forKey: "hasProtectedContent", error: &error) == .loaded {
                // Access the property value synchronously.
                if asset.hasProtectedContent {
                    adapter.drmType = DrmType.fairplay.rawValue
                } else {
                    adapter.drmType = nil
                }
            }
        }
    }
    
    func updateVideoBitrate(videoBitrate: Double) {
        currentVideoQuality = getVideoQualityDto(videoBitrate: videoBitrate)
    }
    
    func getVideoQualityDto(videoBitrate: Double) -> VideoQualityDto {
        
        let videoQuality = VideoQualityDto()
        videoQuality.videoBitrate = videoBitrate
        
        // videoPlaybackWidth
        if let width = player.currentItem?.presentationSize.width {
            videoQuality.videoWidth = Int(width)
        }

        // videoPlaybackHeight
        if let height = player.currentItem?.presentationSize.height {
            videoQuality.videoHeight = Int(height)
        }
        
        return videoQuality
    }

    private func getAudioBitrateFromProgressivePlayerItem(forItem playerItem: AVPlayerItem?) -> Float64? {
        // audio bitrate for progressive sources
        guard let asset = playerItem?.asset else {
            return nil
        }
        if asset.tracks.isEmpty {
            return nil
        }
        
        let tracks = asset.tracks(withMediaType: .audio)
        if tracks.isEmpty {
            return nil
        }
        
        let desc = tracks[0].formatDescriptions[0] as! CMAudioFormatDescription
        let basic = CMAudioFormatDescriptionGetStreamBasicDescription(desc)
        
        guard let sampleRate = basic?.pointee.mSampleRate else {
            return nil
        }
        
        return sampleRate
    }
    
    private func setDownloadSpeedInfo(eventData: EventData) {
        
        if let downloadSpeedInfo = downloadSpeedDetectionService.getDownloadSpeedInfo() {
            eventData.downloadSpeedInfo = downloadSpeedInfo
        }
        
        // we skip taking a snapshot for startup to count the time spend in this state to the download segment time
        if eventData.state == "startup" {
            return
        }
        
        downloadSpeedDetectionService.saveSnapshot()
    }
}
