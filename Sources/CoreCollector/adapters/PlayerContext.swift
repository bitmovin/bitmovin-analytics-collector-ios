import CoreMedia

public protocol PlayerContext {
    var position: CMTime? { get }
    var isLive: Bool? { get }
}
