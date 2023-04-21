import AmazonIVSPlayer

// We created our own protocol to work with and also to enable proper mocking of that class
internal protocol IVSQualityProtocol: AnyObject {
    var name: String { get }
    var codecs: String { get }
    var bitrate: Int { get }
    var width: Int { get }
    var height: Int { get }
}

// with this extension we enable us to use instances of IVSQuality from the AmazonIVSPlayer package
// without using the protocol directly
extension IVSQuality: IVSQualityProtocol {}
