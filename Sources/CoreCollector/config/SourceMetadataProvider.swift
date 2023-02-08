import Foundation

public class SourceMetadataProvider<TSource: AnyObject>: NSObject {
    private var sources: Array<(key: TSource, value: SourceMetadata)> = []
    
    public func add(source: TSource, sourceMetadata: SourceMetadata) {
        
        let sourceIndex = sources.firstIndex { (s) -> Bool in
            s.key === source
        }
        
        if let index = sourceIndex {
            self.sources.remove(at: index)
        }
        
        let pair = (key: source, value: sourceMetadata)
        self.sources.append(pair)
    }
    
    public func get(source: TSource?) -> SourceMetadata? {
        
        guard let p = source else {
            return nil
        }
        
        return sources.first { (s) -> Bool in
            s.key === p
        }?.value
    }
    
    public func clear() {
        sources.removeAll()
    }
}
