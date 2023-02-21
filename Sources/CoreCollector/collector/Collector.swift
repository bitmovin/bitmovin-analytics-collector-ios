import Foundation

public protocol Collector {
    associatedtype TPlayer

    func attachPlayer(player: TPlayer)
    func detachPlayer()

    func getCustomData() -> CustomData
    func setCustomData(customData: CustomData)
    func setCustomDataOnce(customData: CustomData)

    func getUserId() -> String
}
