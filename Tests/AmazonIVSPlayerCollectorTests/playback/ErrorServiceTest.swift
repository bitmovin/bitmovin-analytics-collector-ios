import AVFoundation
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSPlayerCollector
import CoreCollector

class ErrorServiceTest: QuickSpec {
    override func spec() {
        
        // arrange
        var mockStateMachine = MockStateMachine()
        var mockPlayerContext = MockPlayerContext()
        var errorService = ErrorService(
            playerContext: mockPlayerContext,
            stateMachine: mockStateMachine
        )
        beforeEach {
            mockStateMachine = MockStateMachine()
            mockPlayerContext = MockPlayerContext()
            errorService = ErrorService(
                playerContext: mockPlayerContext,
                stateMachine: mockStateMachine
            )
        }
        
        describe("onError") {
            it("should transition onPlayAttemptFailed") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.onPlayAttemptFailed(withReason: any(), withError: any())).thenDoNothing()
                    when(stub.error(withError: any(), time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(false)
                    when(stub.didAttemptPlayingVideo.get).thenReturn(true)
                }
                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }
                let error = NSError(domain: "test", code: 0,
                                    userInfo: [
                                        NSLocalizedDescriptionKey : "test-localized-description",
                                        NSLocalizedFailureReasonErrorKey: "test-localized-failure-reason"
                                    ]
                )
                let errorData = ErrorData(code: 0,
                                          message: "test-localized-description",
                                          data: "test-localized-failure-reason"
                )

                // act
                errorService.onError(error: error)

                // assert
                verify(mockStateMachine).onPlayAttemptFailed(withReason: equal(to: VideoStartFailedReason.playerError), withError:
                                                                equal (to: errorData))
            }

            it("should transition to error") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.onPlayAttemptFailed(withReason: any(), withError: any())).thenDoNothing()
                    when(stub.error(withError: any(), time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(true)
                    when(stub.didAttemptPlayingVideo.get).thenReturn(true)
                }
                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }
                let error = NSError(domain: "test", code: 0,
                                    userInfo: [
                                        NSLocalizedDescriptionKey : "test-localized-description",
                                        NSLocalizedFailureReasonErrorKey: "test-localized-failure-reason"
                                    ]
                )
                let errorData = ErrorData(code: 0,
                                          message: "test-localized-description",
                                          data: "test-localized-failure-reason"
                )

                // act
                errorService.onError(error: error)

                // assert
                verify(mockStateMachine).error(withError: equal (to: errorData), time: equal(to: position))
            }
            
        }
    }
}
