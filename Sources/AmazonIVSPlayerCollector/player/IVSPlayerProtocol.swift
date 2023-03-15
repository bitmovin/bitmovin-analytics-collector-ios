import AmazonIVSPlayer

// add here api you want to mock
protocol IVSPlayerProtocol : AnyObject{
    var videoFramesDropped: Int { get }
}

extension IVSPlayer: IVSPlayerProtocol {}
