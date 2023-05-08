import AmazonIVSPlayer
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector

class PlaybackQualityProviderTests: QuickSpec {
    override class func spec() {
        // These tests don't cover cases where both qualities are not nil
        // The actual equality check should be performed by the AmazonIVSPlayer lib
        describe("didVideoChange") {
            it("should return false if both qualities are nil") {
                // arrange
                let qualityProvider = DefaultPlaybackQualityProvider()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: nil)

                // assert
                expect(didChange).to(beFalse())
            }
            it("should return true if new quality is nil") {
                // arrange
                let qualityProvider = DefaultPlaybackQualityProvider()
                qualityProvider.currentQuality = MockIVSQualityProtocol()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: nil)

                // assert
                expect(didChange).to(beTrue())
            }
            it("should return true if new quality is not nil") {
                // arrange
                let qualityProvider = DefaultPlaybackQualityProvider()

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: MockIVSQualityProtocol())

                // assert
                expect(didChange).to(beTrue())
            }
            it("should return true if quality is not equal") {
                // arrange
                let qualityProvider = DefaultPlaybackQualityProvider()
                let quality1 = MockIVSQualityProtocol()
                stub(quality1) { stub in
                    when(stub.name.get).thenReturn("1080p")
                    when(stub.codecs.get).thenReturn("codec1")
                    when(stub.bitrate.get).thenReturn(1_080_000)
                    when(stub.width.get).thenReturn(1234)
                    when(stub.height.get).thenReturn(4321)
                }
                qualityProvider.currentQuality = quality1

                let quality2 = MockIVSQualityProtocol()
                stub(quality2) { stub in
                    when(stub.name.get).thenReturn("720p")
                    when(stub.codecs.get).thenReturn("codec2")
                    when(stub.bitrate.get).thenReturn(720_000)
                    when(stub.width.get).thenReturn(123)
                    when(stub.height.get).thenReturn(321)
                }

                // act
                let didChange = qualityProvider.didQualityChange(newQuality: quality2)

                // assert
                expect(didChange).to(beTrue())
            }
            it("should return false if quality is equal") {
                // arrange
                let qualityProvider = DefaultPlaybackQualityProvider()
                let quality1 = MockIVSQualityProtocol()
                stub(quality1) { stub in
                    when(stub.name.get).thenReturn("1080p")
                    when(stub.codecs.get).thenReturn("codec1")
                    when(stub.bitrate.get).thenReturn(1_080_000)
                    when(stub.width.get).thenReturn(1234)
                    when(stub.height.get).thenReturn(4321)
                }
                qualityProvider.currentQuality = quality1
                // act
                let didChange = qualityProvider.didQualityChange(newQuality: quality1)

                // assert
                expect(didChange).to(beFalse())
            }
        }
    }
}
