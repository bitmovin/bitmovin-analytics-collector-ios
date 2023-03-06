import AVFoundation
import Nimble
import Quick

class CMTimeExtentionTests: QuickSpec {
    override func spec() {
        it("should return correct value") {
            // arrange
            let time = CMTimeMakeWithSeconds(123, preferredTimescale: 1_000)

            // act
            let timeInMillis = time.toMillis()

            // assert
            expect(timeInMillis).to(equal(123_000))
        }
    }
}
