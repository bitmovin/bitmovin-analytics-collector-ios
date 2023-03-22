internal protocol PlayingHeartbeatListener: AnyObject {
    func onPlayingHeartbeat() -> Bool
}

internal protocol RebufferHeartbeatListener: AnyObject {
    func onRebufferHeartbeat()
}
