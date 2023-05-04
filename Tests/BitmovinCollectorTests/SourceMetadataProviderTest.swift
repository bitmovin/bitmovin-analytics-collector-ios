import XCTest
@testable import BitmovinCollector
@testable import CoreCollector

class SourceMetadataProviderTest: XCTestCase {
    class TestSource: NSObject {
        var id: String = ""
    }
    private var sourceProvider = SourceMetadataProvider<NSObject>()
    let redbull: String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"

    func test_add_and_get_should_add_and_retreive_correct_source_metadata_reference() {
        // arrange

        let source = TestSource()
        source.id = "sourceId"
        let expectedSourceMetadata = SourceMetadata(videoId: "test")

        // act
        sourceProvider.add(source: source, sourceMetadata: expectedSourceMetadata)
        let sourceMetadata = sourceProvider.get(source: source)

        // assert
        XCTAssertTrue(expectedSourceMetadata == sourceMetadata)
    }
}
