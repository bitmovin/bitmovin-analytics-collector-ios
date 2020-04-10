import Foundation

class CorePlayerAdapter: NSObject {
    internal var stateMachine: StateMachine
    internal var didVideoPlay: Bool
    internal var isPlayerReady: Bool
    internal var didAttemptPlay: Bool
    internal var videoStartFailed: Bool
    internal var videoStartFailedReason: String?
    internal var isVideoStartTimerActive: Bool
    internal var videoStartTimeoutSeconds: TimeInterval = 60
    
    internal var delegate: PlayerAdapter!
    
    init(stateMachine: StateMachine){
        self.stateMachine = stateMachine
        self.didAttemptPlay = false
        self.didVideoPlay = false
        self.isVideoStartTimerActive = false
        self.videoStartFailedReason = nil
        self.videoStartFailed = false
        self.isPlayerReady = false
        super.init()
    }
    
    
    func destroy() {
        self.delegate.stopMonitoring()
        
        if (!didVideoPlay && didAttemptPlay) {
            self.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
        
        self.isPlayerReady = false
    }
    
    func onPlayAttemptFailed(withReason reason: String = VideoStartFailedReason.unknown) {
        videoStartFailed = true
        videoStartFailedReason = reason
        stateMachine.transitionState(destinationState: .playAttemptFailed, time: self.delegate.currentTime)
    }
    
    func setVideoStartTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.videoStartTimeoutSeconds) {
            if (self.isVideoStartTimerActive)
            {
                self.onPlayAttemptFailed(withReason: VideoStartFailedReason.timeout)
            }
        }
        isVideoStartTimerActive = true
    }
    
    func clearVideoStartTimer() {
        isVideoStartTimerActive = false
    }

}
