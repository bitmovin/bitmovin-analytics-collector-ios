import AVFoundation
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSCollector
import CoreCollector

class VideoStartupServiceTest: QuickSpec {
    override func spec() {
        // arrange
        var mockStateMachine = MockStateMachine()
        var mockPlayerContext = MockPlayerContext()
        var mockPlayer = MockIVSPlayerProtocol()
        var mockQualityProvider = MockPlaybackQualityProvider()
        var videoStartupService = DefaultVideoStartupService(
            playerContext: mockPlayerContext,
            stateMachine: mockStateMachine,
            player: mockPlayer,
            playbackQualityProvider: mockQualityProvider
        )
        beforeEach {
            mockStateMachine = MockStateMachine()
            mockPlayerContext = MockPlayerContext()
            mockPlayer = MockIVSPlayerProtocol()
            mockQualityProvider = MockPlaybackQualityProvider()
            videoStartupService = DefaultVideoStartupService(
                playerContext: mockPlayerContext,
                stateMachine: mockStateMachine,
                player: mockPlayer,
                playbackQualityProvider: mockQualityProvider
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
                    when(stub.play(time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(false)
                }

                let position = CMTime(seconds: 1, preferredTimescale: 1_000)
                stub(mockPlayerContext) { stub in
                    when(stub.position.get).thenReturn(position)
                }

                let quality: IVSQualityProtocol = IVSQualityProtocolStub()
                stub(mockPlayer) { stub in
                    when(stub.qualityProtocol).get.thenReturn(quality)
                }

                var receivedQuality: IVSQualityProtocol?
                stub(mockQualityProvider) { stub in
                    when(stub.currentQuality.set(any())).then { quality in
                        receivedQuality = quality
                    }
                }

                // act
                videoStartupService.onStateChange(state: .playing)

                // assert
                verify(mockStateMachine).play(time: isNil())
                verify(mockStateMachine).playing(time: equal(to: position))
                expect(receivedQuality).to(beIdenticalTo(quality))
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
                verify(mockQualityProvider, times(0)).currentQuality.set(any())
            }
            it("should call play when in state buffering") {
                // arrange
                stub(mockStateMachine) { stub in
                    when(stub.play(time: any())).thenDoNothing()
                    when(stub.didStartPlayingVideo.get).thenReturn(false)
                }

                let quality: IVSQualityProtocol = IVSQualityProtocolStub()
                stub(mockPlayer) { stub in
                    when(stub.qualityProtocol).get.thenReturn(quality)
                }

                var receivedQuality: IVSQualityProtocol?
                stub(mockQualityProvider) { stub in
                    when(stub.currentQuality.set(any())).then { quality in
                        receivedQuality = quality
                    }
                }

                // act
                videoStartupService.shouldStartup(state: .buffering)

                // assert
                verify(mockStateMachine, times(1)).play(time: isNil())
                verify(mockStateMachine, times(0)).playing(time: any())
                expect(receivedQuality).to(beIdenticalTo(quality))
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

                let quality: IVSQualityProtocol = IVSQualityProtocolStub()
                stub(mockPlayer) { stub in
                    when(stub.qualityProtocol).get.thenReturn(quality)
                }

                var receivedQuality: IVSQualityProtocol?
                stub(mockQualityProvider) { stub in
                    when(stub.currentQuality.set(any())).then { quality in
                        receivedQuality = quality
                    }
                }

                // act
                videoStartupService.shouldStartup(state: .playing)

                // assert
                verify(mockStateMachine, times(1)).play(time: isNil())
                verify(mockStateMachine, times(1)).playing(time: equal(to: position))
                expect(receivedQuality).to(beIdenticalTo(quality))
            }
        }
    }
}
