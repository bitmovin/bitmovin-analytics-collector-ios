import AmazonIVSPlayer

// add here api you want to mock
protocol IVSPlayerProtocol: AnyObject {
    var videoFramesDropped: Int { get }
    var version: String { get }
    var delegate: IVSPlayer.Delegate? { get set }
    var state: IVSPlayer.State { get }
    var qualityProtocol: IVSQualityProtocol? { get }
    var muted: Bool { get }
    var path: URL? { get }
    var duration: CMTime { get }
}

extension IVSPlayer: IVSPlayerProtocol {
    var qualityProtocol: IVSQualityProtocol? {
        self.quality
    }
}
