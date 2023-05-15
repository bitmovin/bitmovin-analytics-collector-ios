import AmazonIVSPlayer
import Nimble
import Quick
import Cuckoo

@testable import AmazonIVSPlayerCollector

class PlayerStatisticsProviderTests: QuickSpec {
    override class func spec() {
        describe("reset") {
            it("should reset saved values to 0") {
                // arrange
                let mockedPlayer = MockIVSPlayerProtocol()
                stub(mockedPlayer) { stub in
                    when(stub.videoFramesDropped.get).thenReturn(10).thenReturn(25)
                }
                let statProvider = DefaultPlayerStatisticsProvider(player: mockedPlayer)
                _ = statProvider.getDroppedFramesDelta()

                // act
                statProvider.reset()

                // assert
                let droppedFrames = statProvider.getDroppedFramesDelta()
                expect(droppedFrames).to(equal(25))
            }
        }
        describe("getDroppedFramesDelta") {
            it("should return the correct value if called once") {
                // arrange
                let mockedPlayer = MockIVSPlayerProtocol()
                stub(mockedPlayer) { stub in
                    when(stub.videoFramesDropped.get).thenReturn(10)
                }
                let statProvider = DefaultPlayerStatisticsProvider(player: mockedPlayer)

                // act
                let droppedFrames = statProvider.getDroppedFramesDelta()

                // assert
                expect(droppedFrames).to(equal(10))
                verify(mockedPlayer, times(1)).videoFramesDropped.get()
            }
            it("should return the correct value if called twice") {
                // arrange
                let mockedPlayer = MockIVSPlayerProtocol()
                stub(mockedPlayer) { stub in
                    when(stub.videoFramesDropped.get).thenReturn(5).thenReturn(15)
                }
                let statProvider = DefaultPlayerStatisticsProvider(player: mockedPlayer)

                // act
                let droppedFrames1 = statProvider.getDroppedFramesDelta()
                let droppedFrames2 = statProvider.getDroppedFramesDelta()

                // assert
                expect(droppedFrames1).to(equal(5))
                expect(droppedFrames2).to(equal(10))
                verify(mockedPlayer, times(2)).videoFramesDropped.get()
            }
        }
    }
}
