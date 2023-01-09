import Foundation
import BitmovinPlayer

// This class could be used as a base for the interface EventDataDecorator
class CastEventDataDecorator {
    private final var player: Player
    
    private var isCasting = false
    private var castTech: String?
    
    init(player: Player) {
        self.player = player
    }
    
    // it first applies the data it has and then updates the information it holds
    // this delays the setting of the values by one sample
    func decorate(_ eventData: EventData) {
        applyCastInfo(to: eventData)
        updateCastInfo()
    }
    
    private func applyCastInfo(to eventData: EventData) {
        eventData.isCasting = self.isCasting
        if eventData.isCasting {
            eventData.castTech = self.castTech
        } else {
            eventData.castTech = nil
        }
    }
    
    private func updateCastInfo() {
        self.isCasting = fetchIsCastingFromPlayer()
        self.castTech = fetchCastTechFromPlayer()
    }
    
    private func fetchIsCastingFromPlayer() -> Bool {
        return player.isCasting || player.isAirPlayActive
    }
    
    private func fetchCastTechFromPlayer() -> String {
        return player.isAirPlayActive ? CastTech.AirPlay.rawValue : CastTech.GoogleCast.rawValue
    }
}
