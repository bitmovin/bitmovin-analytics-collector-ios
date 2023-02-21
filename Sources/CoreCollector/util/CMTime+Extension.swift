import AVFoundation

public extension CMTime {
    func toMillis() -> Int64 {
        let msPerSec = 1_000.0
        return Int64(CMTimeGetSeconds(self) * msPerSec)
    }
}
