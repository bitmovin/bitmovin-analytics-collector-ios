#if SWIFT_PACKAGE
import CoreCollector
#endif
import AmazonIVSPlayer

class DefaultPlaybackQualityProvider: PlaybackQualityProvider {
    var currentQuality: IVSQualityProtocol?

    func didQualityChange(newQuality: IVSQualityProtocol?) -> Bool {
        if areBothNil(newQuality, currentQuality) {
            return false
        }

        if isOnlyOneNil(newQuality, currentQuality) {
            return true
        }

        return newQuality!.isEqual(to: self.currentQuality! as! IVSQuality)
    }

    func reset() {
        self.currentQuality = nil
    }

    private func areBothNil(_ quality1: IVSQualityProtocol?, _ quality2: IVSQualityProtocol?) -> Bool {
        quality1 == nil && quality2 == nil
    }

    private func isOnlyOneNil(_ quality1: IVSQualityProtocol?, _ quality2: IVSQualityProtocol?) -> Bool {
        (quality1 == nil && quality2 != nil) ||
            (quality1 != nil && quality2 == nil)
    }

}
