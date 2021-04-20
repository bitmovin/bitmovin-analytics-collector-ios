import BitmovinPlayer

internal class BitmovinSourceMetadataProvider: NSObject {
    private var sources: Array<BitmovinSourceMetadata> = []
    
    func add(sourceMetadata: BitmovinSourceMetadata) {
        
        let sourceIndex = sources.firstIndex(where: { (s) -> Bool in
            s.playerSource === sourceMetadata.playerSource
        })
        
        if let index = sourceIndex {
            self.sources.remove(at: index)
        }
        
        self.sources.append(sourceMetadata)
    }
    
    func get(playerSource: Source?) -> BitmovinSourceMetadata? {
        
        guard let p = playerSource else {
            return nil
        }
        
        return sources.first(where: { (s) -> Bool in
            s.playerSource === p
        })
    }
}

