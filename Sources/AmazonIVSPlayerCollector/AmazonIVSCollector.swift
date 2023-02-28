import AmazonIVSPlayer
#if SWIFT_PACKAGE
import CoreCollector
#endif

@objc
public class AmazonIVSCollector: NSObject, Collector {
    public typealias TPlayer = IVSPlayer

    public func attachPlayer(player: IVSPlayer) {
        
    }

    public func detachPlayer() {

    }

    public func getCustomData() -> CustomData {

        return CustomData()
    }

    public func setCustomData(customData: CustomData) {

    }

    public func setCustomDataOnce(customData: CustomData) {

    }

    public func getUserId() -> String {
        return ""
    }
}
