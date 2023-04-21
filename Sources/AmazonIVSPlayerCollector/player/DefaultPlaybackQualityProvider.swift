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

        return !isEqualByProperties(newQuality, self.currentQuality)
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

    private func isEqualByProperties(_ quality1: IVSQualityProtocol?, _ quality2: IVSQualityProtocol?) -> Bool {
        quality1?.name == quality2?.name &&
        quality1?.width == quality2?.width &&
        quality1?.height == quality2?.height &&
        quality1?.bitrate == quality2?.bitrate &&
        quality1?.codecs == quality2?.codecs
    }

}
