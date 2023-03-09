import AVFoundation

public extension CMTime {
    func toMillis() -> Int64? {
        let msPerSec = 1_000.0
        if !canConvertToMillis(self) {
            return nil
        }
        let val = CMTimeGetSeconds(self)
        if val.isNaN || val.isInfinite {
            return nil
        }
        return Int64(val * msPerSec)
    }

    private func canConvertToMillis(_ time: CMTime) -> Bool {
        self.isValid &&
        !self.isIndefinite &&
        !self.isNegativeInfinity &&
        !self.isPositiveInfinity
    }
}
