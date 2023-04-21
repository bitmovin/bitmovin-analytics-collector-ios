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
        var mockPlaybackQualityProvider = MockPlaybackQualityProvider()
        var mockStatisticProvider = MockPlayerStatisticsProvider()
        var playbackService = DefaultPlaybackService(
            playerContext: mockPlayerContext,
            stateMachine: mockStateMachine,
            qualityProvider: mockPlaybackQualityProvider,
            statisticsProvider: mockStatisticProvider
        )
        beforeEach {
            mockStateMachine = MockStateMachine()
            mockPlayerContext = MockPlayerContext()
            mockPlaybackQualityProvider = MockPlaybackQualityProvider()
            mockStatisticProvider = MockPlayerStatisticsProvider()
            playbackService = DefaultPlaybackService(
                playerContext: mockPlayerContext,
                stateMachine: mockStateMachine,
                qualityProvider: mockPlaybackQualityProvider,
                statisticsProvider: mockStatisticProvider
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

        describe("onBuffering") {
            it("should transition into buffering state") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.transitionState(destinationState: any(), time: any())).thenDoNothing()
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                // act
                playbackService.onBuffering()

                // assert
                verify(mockStateMachine).transitionState(destinationState: equal(to: PlayerState.buffering), time: equal(to: position))
            }
        }

        describe("onSeekCompleted") {
            it("should not transition into seek state if live stream") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.transitionState(destinationState: any(), time: any())).thenDoNothing()
                    when(stub.seek(time: any())).thenDoNothing()
                    when(stub.state.get).thenReturn(PlayerState.playing)
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                    when(stub.isLive.get).thenReturn(true)
                }
                let seekToTime = CMTime(seconds: 5, preferredTimescale: 1_000)

                // act
                playbackService.onSeekCompleted(time: seekToTime)

                // assert
                verify(mockStateMachine, never()).seek(time: any())
            }
            it("should not transition into seek state when no info") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.transitionState(destinationState: any(), time: any())).thenDoNothing()
                    when(stub.seek(time: any())).thenDoNothing()
                    when(stub.state.get).thenReturn(PlayerState.playing)
                }

                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(nil)
                    when(stub.isLive.get).thenReturn(nil)
                }
                let seekToTime = CMTime(seconds: 5, preferredTimescale: 1_000)

                // act
                playbackService.onSeekCompleted(time: seekToTime)

                // assert
                verify(mockStateMachine, never()).seek(time: any())
            }
            it("should transition from playing to seek and back") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.transitionState(destinationState: any(), time: any())).thenDoNothing()
                    when(stub.seek(time: any())).thenDoNothing()
                    when(stub.state.get).thenReturn(PlayerState.playing)
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                    when(stub.isLive.get).thenReturn(false)
                }
                let seekToTime = CMTime(seconds: 5, preferredTimescale: 1_000)

                // act
                playbackService.onSeekCompleted(time: seekToTime)

                // assert
                verify(mockStateMachine, times(1)).seek(time: equal(to: seekToTime))
                verify(mockStateMachine, times(1)).transitionState(destinationState: equal(to: PlayerState.playing), time: equal(to: seekToTime))
            }
        }

        describe("onQualityChange") {
            it("should not cause state transition when quality was not set before ") {
                // arrange
                var receivedQuality: IVSQualityProtocol?
                stub(mockPlaybackQualityProvider) { stub in
                    when(stub.currentQuality.get).thenReturn(nil)
                    when(stub.currentQuality.set(any())).then { quality in
                        receivedQuality = quality
                    }
                }
                let quality: IVSQualityProtocol = IVSQualityProtocolStub()
                
                // act

                playbackService.onQualityChange(quality)

                // assert
                expect(receivedQuality) === quality
                verify(mockStateMachine, times(0)).videoQualityChange(time: any(), setQualityFunction: any())
                verify(mockStatisticProvider, times(0)).reset()
            }
            it("should call videoQualityChange on statemachine and reset statistics") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.videoQualityChange(time: any(), setQualityFunction: any())).thenDoNothing()
                }

                let position = CMTime(seconds: 100, preferredTimescale: CMTimeScale())

                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                stub(mockStatisticProvider) { stub in
                    when(stub.reset()).thenDoNothing()
                }

                stub(mockPlaybackQualityProvider) { stub in
                    when(stub.didQualityChange(newQuality: any())).thenReturn(true)
                }

                stub(mockPlaybackQualityProvider) { stub in
                    when(stub.currentQuality.get).thenReturn(MockIVSQualityProtocol())
                }

                // act
                playbackService.onQualityChange(MockIVSQualityProtocol())

                // assert
                verify(mockStateMachine, times(1)).videoQualityChange(time: equal(to: position), setQualityFunction: any())

                verify(mockStatisticProvider, times(1)).reset()
            }
        }
    }
}
