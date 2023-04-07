import AmazonIVSPlayer

// add here api you want to mock
protocol IVSPlayerProtocol: AnyObject {
    var videoFramesDropped: Int { get }
    var version: String { get }
    var delegate: IVSPlayer.Delegate? { get set }
    var state: IVSPlayer.State { get }
}

extension IVSPlayer: IVSPlayerProtocol {}
