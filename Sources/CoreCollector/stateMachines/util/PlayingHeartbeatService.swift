import Foundation

class PlayingHeartbeatService {
    private var heartbeatTimer: Timer?
    private let heartbeatInterval: Int = 59_700
    weak var listener: PlayingHeartbeatListener?

    deinit {
        disableHeartbeat()
    }

    func enableHeartbeat() {
        let interval = Double(heartbeatInterval) / 1_000.0
        heartbeatTimer?.invalidate()
        executeOnMain {
            heartbeatTimer = Timer.scheduledTimer(
                timeInterval: interval,
                target: self,
                selector: #selector(PlayingHeartbeatService.onHeartbeat),
                userInfo: nil,
                repeats: true
            )
        }
    }

    func disableHeartbeat() {
        heartbeatTimer?.invalidate()
    }

    @objc
    private func onHeartbeat() {
        guard let listener = self.listener else {
            disableHeartbeat()
            return
        }
        let cont = listener.onPlayingHeartbeat()
        if !cont {
            disableHeartbeat()
        }
    }

    private func executeOnMain(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
}
