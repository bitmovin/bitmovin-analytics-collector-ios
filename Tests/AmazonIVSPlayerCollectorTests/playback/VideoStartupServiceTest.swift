import AVFoundation
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector
import CoreCollector

class VideoStartupServiceTest: QuickSpec {
    override func spec() {
        // arrange
        var mockStateMachine = MockStateMachine()
        var mockPlayerContext = MockPlayerContext()
        var videoStartupService = VideoStartupService(
            playerContext: mockPlayerContext,
            stateMachine: mockStateMachine
        )
        beforeEach {
            mockStateMachine = MockStateMachine()
            mockPlayerContext = MockPlayerContext()
            videoStartupService = VideoStartupService(
                playerContext: mockPlayerContext,
                stateMachine: mockStateMachine
            )
        }

        describe("onStateChange") {
            it("should transition into startup when state is buffering") {
                // arrange
                stub(mockStateMachine) {stub in
                    when(stub.play(time: any())).thenDoNothing()
                }

                // act
                videoStartupService.onStateChange(state: .buffering)

                // assert
                verify(mockStateMachine).play(time: isNil())
            }
            it("should transition into playing when state is playing") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.playing(time: any())).thenDoNothing()
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                // act
                videoStartupService.onStateChange(state: .playing)

                // assert
                verify(mockStateMachine).playing(time: equal(to: position))
            }
        }

        describe("shouldStartup") {
            it("should do nothing when startup already happened") {
                // arrange
                stub(mockStateMachine) {stub in
                    when(stub.didStartPlayingVideo.get).thenReturn(true)
                }

                // act
                videoStartupService.shouldStartup(state: .playing)

                // assert
                verify(mockStateMachine, times(0)).play(time: any())
                verify(mockStateMachine, times(0)).playing(time: any())
            }
            it("should call play when in state buffering") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.play(time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(false)
                }

                // act
                videoStartupService.shouldStartup(state: .buffering)

                // assert
                verify(mockStateMachine, times(1)).play(time: isNil())
                verify(mockStateMachine, times(0)).playing(time: any())
            }
            it("should call play and playing when in state playing") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.playing(time: any())).thenDoNothing()
                    when(stub.play(time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(false)
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                // act
                videoStartupService.shouldStartup(state: .playing)

                // assert
                verify(mockStateMachine, times(1)).play(time: isNil())
                verify(mockStateMachine, times(1)).playing(time: equal(to: position))
            }
        }
    }
}
