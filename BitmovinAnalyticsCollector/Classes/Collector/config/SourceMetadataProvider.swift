internal class SourceMetadataProvider<TSource>: NSObject {

    private let equalComparator: (TSource, TSource) -> Bool
    private var sources: Array<(key: TSource, value: SourceMetadata)> = []
    
    internal init(comparer: @escaping (TSource, TSource) -> Bool) {
        self.equalComparator = comparer
    }
    
    func add(source: TSource, sourceMetadata: SourceMetadata) {
        
        let sourceIndex = sources.firstIndex(where: { (s) -> Bool in
            equalComparator(s.key, source)
        })
        
        if let index = sourceIndex {
            self.sources.remove(at: index)
        }
        
        let pair = (key: source, value: sourceMetadata)
        self.sources.append(pair)
    }
    
    func get(source: TSource?) -> SourceMetadata? {
        
        guard let p = source else {
            return nil
        }
        
        return sources.first(where: { (s) -> Bool in
            equalComparator(s.key, p)
        })?.value
    }
    
    func clear() {
        sources.removeAll()
    }
}
