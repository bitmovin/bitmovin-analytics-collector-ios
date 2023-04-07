internal protocol PlaybackQualityProvider : AnyObject {
    var currentQuality: IVSQualityProtocol? { get set }
    func didQualityChange(newQuality: IVSQualityProtocol?) -> Bool
    func reset()
}
