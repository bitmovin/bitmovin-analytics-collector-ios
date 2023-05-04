internal protocol PlayerStatisticsProvider {
    func getDroppedFramesDelta() -> Int
    func reset()
}
