import Foundation

public class SourceMetadataProvider<TSource: AnyObject>: NSObject {
    private var sources: [(key: TSource, value: SourceMetadata)] = []

    public func add(source: TSource, sourceMetadata: SourceMetadata) {
        let sourceIndex = sources.firstIndex { src -> Bool in
            src.key === source
        }

        if let index = sourceIndex {
            self.sources.remove(at: index)
        }

        let pair = (key: source, value: sourceMetadata)
        self.sources.append(pair)
    }

    public func get(source: TSource?) -> SourceMetadata? {
        guard let source = source else {
            return nil
        }

        return sources.first { src -> Bool in
            src.key === source
        }?.value
    }

    public func clear() {
        sources.removeAll()
    }
}
