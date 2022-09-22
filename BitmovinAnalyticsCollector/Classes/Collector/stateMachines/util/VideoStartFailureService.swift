//
//  VideoStartFailureService.swift
//  Pods
//
//  Created by Thomas Sablattnig on 22.09.22.
//

import Foundation

public class VideoStartFailureService {
    private static var videoStartFailedTimeoutSeconds: TimeInterval = 60
    
    private weak var stateMachine: StateMachine?
    
    private var videoStartFailedWorkItem: DispatchWorkItem?
    private let queue = DispatchQueue.init(label: "com.bitmovin.analytics.core.utils.VideoStartFailureService")
    
    public private(set) var videoStartFailed: Bool = false
    public private(set) var videoStartFailedReason: String?
    
    func initialise(stateMachine: StateMachine) {
        self.stateMachine = stateMachine
    }
    
    public func startVideoStartFailedTimer() {
        guard let stateMachine = self.stateMachine else {
            return
        }
        
        // The second test makes sure to not start the timer during an ad or if the player is paused on resuming from background
        if(stateMachine.didStartPlayingVideo || stateMachine.state != .startup) {
            return
        }
        clearVideoStartFailedTimer()
        
        videoStartFailedWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.stateMachine?.onPlayAttemptFailed(withReason: VideoStartFailedReason.timeout, withError: ErrorData.ANALYTICS_VIDEOSTART_TIMEOUT_REACHED)
        }
        queue.asyncAfter(deadline: .now() + VideoStartFailureService.videoStartFailedTimeoutSeconds, execute: videoStartFailedWorkItem!)
    }
    
    public func clearVideoStartFailedTimer() {
        if (videoStartFailedWorkItem == nil) {
            return
        }
        videoStartFailedWorkItem!.cancel()
        videoStartFailedWorkItem = nil
    }
    
    public func setVideoStartFailed(withReason reason: String) {
        clearVideoStartFailedTimer()
        videoStartFailed = true
        videoStartFailedReason = reason
    }
    
    public func resetVideoStartFailed() {
        videoStartFailed = false
        videoStartFailedReason = nil
    }
}
