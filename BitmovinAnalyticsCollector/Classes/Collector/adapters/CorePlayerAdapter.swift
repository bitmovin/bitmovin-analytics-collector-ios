import Foundation

class CorePlayerAdapter: NSObject {
    internal var stateMachine: StateMachine
    internal var didVideoPlay: Bool
    internal var isPlayerReady: Bool
    internal var didAttemptPlay: Bool
    internal var videoStartFailed: Bool
    internal var videoStartFailedReason: String?
    private var videoStartTimer: DispatchWorkItem?
    
    private var videoStartTimeoutSeconds: TimeInterval = 2
    private var videoStartTimerId: String = "com.bitmovin.analytics.coreplayeradapter"
    
    internal var delegate: PlayerAdapter!
    
    init(stateMachine: StateMachine){
        self.stateMachine = stateMachine
        self.didAttemptPlay = false
        self.didVideoPlay = false
        self.videoStartFailedReason = nil
        self.videoStartFailed = false
        self.isPlayerReady = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        if (didVideoPlay) {
            return
        }
        
        if (videoStartTimer != nil) {
            clearVideoStartTimer()
        }
        
        videoStartTimer = DispatchWorkItem {
            self.onPlayAttemptFailed(withReason: VideoStartFailedReason.timeout)
            
        }
        DispatchQueue.init(label: videoStartTimerId).asyncAfter(deadline: .now() + self.videoStartTimeoutSeconds, execute: videoStartTimer!)
    }
    
    func clearVideoStartTimer() {
        if (videoStartTimer == nil) {
            return
        }
        videoStartTimer?.cancel()
        videoStartTimer = nil
    }

    @objc func willResignActive(notification _: Notification){
        clearVideoStartTimer()
    }
    
    @objc func willEnterForegroundNotification(notification _: Notification){
        if(!didVideoPlay && didAttemptPlay) {
            setVideoStartTimer()
        }
    }
    
}
