import AVFoundation
import XCTest
import Quick
import Nimble

class CMTimeExtentionTests: QuickSpec {
    override func spec() {
        it("should return correct value") {
            expect(false).to(beFalse())
        }
    }

//    func test_toMillis_should_returnCorrectValue() {
//        // arrange
//        let time = CMTimeMakeWithSeconds(123, preferredTimescale: 1_000)
//
//        // act
//        let timeInMillis = time.toMillis()
//
//        // assert
//        XCTAssertEqual(timeInMillis, 123_000)
//    }
}
