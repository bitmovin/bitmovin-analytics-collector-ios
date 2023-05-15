import AVFoundation
import Nimble
import Quick

class CMTimeExtentionTests: QuickSpec {
    override class func spec() {
        it("should return correct value") {
            // arrange
            let time = CMTimeMakeWithSeconds(123, preferredTimescale: 1_000)

            // act
            let timeInMillis = time.toMillis()

            // assert
            expect(timeInMillis).to(equal(123_000))
        }
        it("should return nil if value is invalid") {
            // arrange
            let time = CMTime()

            // act
            let invalidTime = time.toMillis()

            // assert
            expect(invalidTime).to(beNil())
        }
        it("should return nil if value is infinity") {
            // arrange
            let time = CMTime(
                value: CMTimeValue(),
                timescale: CMTimeScale(),
                flags: CMTimeFlags.positiveInfinity,
                epoch: CMTimeEpoch()
            )

            // act
            let invalidTime = time.toMillis()

            // assert
            expect(invalidTime).to(beNil())
        }
    }
}
