import AVFoundation
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector
import CoreCollector

class PlaybackServiceTest: QuickSpec {
    override func spec() {
        
        // arrange
        var mockStateMachine = MockStateMachine()
        var mockPlayerContext = MockPlayerContext()
        var playbackService = PlaybackService(
            playerContext: mockPlayerContext,
            stateMachine: mockStateMachine
        )
        beforeEach {
            mockStateMachine = MockStateMachine()
            mockPlayerContext = MockPlayerContext()
            playbackService = PlaybackService(
                playerContext: mockPlayerContext,
                stateMachine: mockStateMachine
            )
        }
        
        describe("onStateChange") {
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
                playbackService.onStateChange(state: .playing)

                // assert
                verify(mockStateMachine).playing(time: equal(to: position))
            }
            
            it("should transition into pause when state is idle") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.pause(time: any())).thenDoNothing()
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                // act
                playbackService.onStateChange(state: .idle)

                // assert
                verify(mockStateMachine).pause(time: equal(to: position))
            }
            
            it("should transition into pause when state is ended") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.pause(time: any())).thenDoNothing()
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                // act
                playbackService.onStateChange(state: .ended)

                // assert
                verify(mockStateMachine).pause(time: equal(to: position))
            }
        }

    }
}
