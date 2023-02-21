import AVFoundation
import XCTest

class CMTimeExtentionTests: XCTestCase {
    func test_toMillis_should_returnCorrectValue() {
        // arrange
        let time = CMTimeMakeWithSeconds(123, preferredTimescale: 1_000)

        // act
        let timeInMillis = time.toMillis()

        // assert
        XCTAssertEqual(timeInMillis, 123_000)
    }
}
