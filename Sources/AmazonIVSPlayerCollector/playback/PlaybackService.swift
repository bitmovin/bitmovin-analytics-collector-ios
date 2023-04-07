import AmazonIVSPlayer
import AVFoundation

internal protocol PlaybackService {
    func onStateChange(state: IVSPlayer.State)
    func onBuffering()
    func onSeekCompleted(time: CMTime)
    func onQualityChange(_ quality: IVSQualityProtocol?)
}
