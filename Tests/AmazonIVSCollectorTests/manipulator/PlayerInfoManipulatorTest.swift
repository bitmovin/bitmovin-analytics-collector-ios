import AmazonIVSPlayer
import Cuckoo
import Nimble
import Quick

@testable import AmazonIVSCollector
@testable import CoreCollector

class PlayerInfoManipulatorTest: QuickSpec {
    override func spec() {
        describe("manipulate") {
            it("should set ivs player_tech, player and player_version") {
                // arrange
                let mockedPlayer = MockIVSPlayerProtocol()
                stub(mockedPlayer) { stub in
                    when(stub.version.get).thenReturn("1.17.0")
                }
                let playerInfoManipulator = PlayerInfoManipulator(player: mockedPlayer)
                let eventData = EventData("dummyImpressionId")

                // act
                playerInfoManipulator.manipulate(eventData: eventData)

                // assert
                expect(eventData.player).to(equal("amazonivs"))
                expect(eventData.playerTech).to(equal("ios:amazonivs"))
                expect(eventData.version).to(equal("amazonivs-1.17.0"))
            }
        }
    }
}
