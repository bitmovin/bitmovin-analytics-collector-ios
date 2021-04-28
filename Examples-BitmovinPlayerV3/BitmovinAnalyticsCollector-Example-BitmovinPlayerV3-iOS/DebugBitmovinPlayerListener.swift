import BitmovinPlayer

class DebugBitmovinPlayerEvents: NSObject, PlayerListener, SourceListener {
    func onEvent(_ event: Event, player: Player) {
        print("DebugBitmovinPlayerEvents onEvent PlayerListener: \(event.name)")
    }
    
    func onEvent(_ event: SourceEvent, source: Source) {
        print("DebugBitmovinPlayerEvents onEvent SourceListener: \(event.name) for source: \(source.sourceConfig.url)")
    }
}
