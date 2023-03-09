import AmazonIVSPlayer
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector

class PlaybackQualityProviderTests: QuickSpec {
    override func spec() {
        // These tests don't cover cases where both qualities are not nil
        // The actual equality check should be performed by the AmazonIVSPlayer lib
        describe("didVideoChange") {
            it("should return false if both qualities are nil") {
                // arrange
                let qualityProvider = PlaybackQualityProvider()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: nil)

                // assert
                expect(didChange).to(beFalse())
            }
            it("should return true if new quality is nil") {
                // arrange
                let qualityProvider = PlaybackQualityProvider()
                qualityProvider.currentQuality = MockIVSQualityProtocol()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: nil)

                // assert
                expect(didChange).to(beTrue())
            }
            it("should return true if new quality is not nil") {
                // arrange
                let qualityProvider = PlaybackQualityProvider()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: MockIVSQualityProtocol())

                // assert
                expect(didChange).to(beTrue())
            }
        }
    }
}
