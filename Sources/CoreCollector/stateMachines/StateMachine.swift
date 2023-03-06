import AVFoundation
import CoreMedia

public protocol StateMachine {
    var state: PlayerState { get }
    var didAttemptPlayingVideo: Bool { get }
    var didStartPlayingVideo: Bool { get }
    var videoStartFailureService: VideoStartFailureService { get }

    func reset()
    func transitionState(destinationState: PlayerState, time: CMTime?)
    func play(time: CMTime?)
    func pause(time: CMTime?)
    func playing(time: CMTime?)
    func seek(time: CMTime?, overrideEnterTimestamp: Int64?)
    func seek(time: CMTime?)
    func videoQualityChange(time: CMTime?, setQualityFunction: @escaping () -> Void)
    func audioQualityChange(time: CMTime?)
    func error(withError error: ErrorData, time: CMTime?)
    func sourceChange(_ previousVideoDuration: CMTime?, _ nextVideotimeStart: CMTime?, _ shouldStartup: Bool)
    func ad(time: CMTime?)
    func adFinished()
    func onPlayAttemptFailed(withReason reason: String, withError error: ErrorData?)
    func onPlayAttemptFailed(withReason reason: String)
    func getErrorData() -> ErrorData?
}
