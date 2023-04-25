import CoreCollector
import AmazonIVSPlayer

class QualityEventDataManipulator: EventDataManipulator {
    private let statisticsProvider: PlayerStatisticsProvider
    private let qualityProvider: PlaybackQualityProvider

    internal init(
        statisticsProvider: PlayerStatisticsProvider,
        qualityProvider: PlaybackQualityProvider
    ) {
        self.statisticsProvider = statisticsProvider
        self.qualityProvider = qualityProvider
    }

    func manipulate(eventData: EventData) throws {
        eventData.droppedFrames = statisticsProvider.getDroppedFramesDelta()

        setQuality(eventData)
    }

    private func setQuality(_ eventData: EventData) {
        guard let quality = qualityProvider.currentQuality else {
            return
        }

        eventData.videoBitrate = Double(quality.bitrate)
        eventData.videoPlaybackWidth = quality.width
        eventData.videoPlaybackHeight = quality.height

        let codecInfo = QualityEventDataManipulator.extractCodeInfo(quality.codecs)
        eventData.videoCodec = codecInfo.videoCodec
        eventData.audioCodec = codecInfo.audioCodec
    }

    private struct CodecInfo {
        var videoCodec: String?
        var audioCodec: String?
    }

    // expected pattern ("avc1.64002A,mp4a.40.2")
    private static func extractCodeInfo(_ codecs: String) -> CodecInfo {
        let splitted = codecs.split(separator: ",")
        guard splitted.count == 2 else {
            return CodecInfo()
        }

        let splittedFirst = String(splitted[0]).trimmingCharacters(in: [" "])
        let splittedSecond = String(splitted[1]).trimmingCharacters(in: [" "])

        var videoCodec: String
        var audioCodec: String

        if CodecUtils.isVideoCodec(splittedFirst) &&
            CodecUtils.isAudioCodec(splittedSecond) {
            videoCodec = splittedFirst
            audioCodec = splittedSecond
        } else {
            videoCodec = splittedSecond
            audioCodec = splittedFirst
        }
        return CodecInfo(
            videoCodec: videoCodec,
            audioCodec: audioCodec
        )
    }
}
