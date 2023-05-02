import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector
@testable import CoreCollector
import CoreMedia

class PlaybackEventDataManipulatorTests: QuickSpec {
    override func spec() {
        describe("manipulate") {
            it("should set all fields correctly") {
                // arrange
                let config = BitmovinAnalyticsConfig(key: "test-key")
                let mockPlayer = MockIVSPlayerProtocol()
                let manipulator = PlaybackEventDataManipulator(
                    player: mockPlayer,
                    config: config
                )

                let duration = CMTimeMakeWithSeconds(10, preferredTimescale: 1_000)
                let path = URL(string: "http://testurl.com")
                stub(mockPlayer) { stub in
                    when(stub.muted.get).thenReturn(true)
                    when(stub.duration.get).thenReturn(duration)
                    when(stub.path.get).thenReturn(path)
                }

                let eventData = EventData("test-impression")

                // act
                try manipulator.manipulate(eventData: eventData)

                // assert
                expect(eventData.isMuted).to(beTrue())
                expect(eventData.videoDuration).to(equal(10_000))
                expect(eventData.isLive).to(beFalse())
                expect(eventData.streamFormat).to(equal(StreamType.hls.rawValue))
                expect(eventData.m3u8Url).to(equal(path?.absoluteString))
            }
            it("should set correct fields for live stream") {
                // arrange
                let config = BitmovinAnalyticsConfig(key: "test-key")
                let mockPlayer = MockIVSPlayerProtocol()
                let manipulator = PlaybackEventDataManipulator(
                    player: mockPlayer,
                    config: config
                )

                let duration = CMTime.indefinite
                let path = URL(string: "http://testurl.com")
                stub(mockPlayer) { stub in
                    when(stub.muted.get).thenReturn(true)
                    when(stub.duration.get).thenReturn(duration)
                    when(stub.path.get).thenReturn(path)
                }

                let eventData = EventData("test-impression")

                // act
                try manipulator.manipulate(eventData: eventData)

                // assert
                expect(eventData.videoDuration).to(equal(0))
                expect(eventData.isLive).to(beTrue())
            }
        }
    }
}
