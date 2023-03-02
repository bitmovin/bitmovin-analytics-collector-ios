import AmazonIVSPlayer

class AmazonIVSPlayerListener: NSObject, IVSPlayer.Delegate {
    private let player: IVSPlayer
    private weak var customerDelegate: IVSPlayer.Delegate?

    init(
        player: IVSPlayer
    ) {
        self.player = player
    }

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        print("We got and player state change \(state)")
        self.customerDelegate?.player?(player, didChangeState: state)
    }

    func startMonitoring() {
        customerDelegate = player.delegate
        player.delegate = self
    }

    func stopMonitoring() {
        player.delegate = customerDelegate
        customerDelegate = nil
    }
}
