import Cuckoo
import Nimble
import Quick

import AmazonIVSPlayer
@testable import AmazonIVSCollector

class AmazonIVSPlayerListenerTests: QuickSpec {
    override func spec() {
        describe("player didChangeQuality") {
            it("should call customerDelegate") {
                // arrange
                var mockPlayer = MockIVSPlayerProtocol()
                var mockStateMachine = MockStateMachine()
                var errorService = MockErrorService()
                var mockPlaybackService = MockPlaybackService()
                stub(mockPlaybackService) { stub in
                    when(stub.onQualityChange(any())).thenDoNothing()
                }
                var mockVideoStartupService = MockVideoStartupService()
                stub(mockVideoStartupService) { stub in
                    when(stub.shouldStartup(state: any())).thenDoNothing()
                }
                let listener = AmazonIVSPlayerListener(
                    player: mockPlayer,
                    videoStartupService: mockVideoStartupService,
                    stateMachine: mockStateMachine,
                    playbackService: mockPlaybackService,
                    errorService: errorService
                )
                let player = IVSPlayer()
                class TestDelegate : NSObject, IVSPlayer.Delegate {
                    var didCall = false
                    func player(_ player: IVSPlayer, didChangeQuality quality: IVSQuality?) {
                        didCall = true
                    }
                }
                let del = TestDelegate()
                stub(mockPlayer) { stub in
                    when(stub.delegate.get).thenReturn(del)
                    when(stub.delegate.set(any())).thenDoNothing()
                    when(stub.state.get).thenReturn(IVSPlayer.State.idle)
                }
                listener.startMonitoring()

                // act
                listener.player(player, didChangeQuality: nil)

                // assert
                expect(del.didCall).to(beTrue())
            }
        }
    }
}
