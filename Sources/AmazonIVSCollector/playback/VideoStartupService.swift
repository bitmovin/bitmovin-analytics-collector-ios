import AmazonIVSPlayer

internal protocol VideoStartupService {
    func onStateChange(state: IVSPlayer.State)
    func shouldStartup(state: IVSPlayer.State)
}
