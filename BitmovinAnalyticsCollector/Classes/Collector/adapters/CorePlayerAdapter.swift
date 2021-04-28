import Foundation

class CorePlayerAdapter: NSObject {
    internal var stateMachine: StateMachine
    private var isDestroyed = false
    
    init(stateMachine: StateMachine){
        self.stateMachine = stateMachine
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func stopMonitoring() {}
    
    func destroy() {
        guard !isDestroyed else {
            return
        }
        isDestroyed = true
        stopMonitoring()
        
        if (!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.onPlayAttemptFailed(withReason: VideoStartFailedReason.pageClosed)
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willResignActive(notification _: Notification){
        stateMachine.clearVideoStartFailedTimer()
    }
    
    @objc func willEnterForegroundNotification(notification _: Notification){
        if(!stateMachine.didStartPlayingVideo && stateMachine.didAttemptPlayingVideo) {
            stateMachine.startVideoStartFailedTimer()
        }
    }
    
}
