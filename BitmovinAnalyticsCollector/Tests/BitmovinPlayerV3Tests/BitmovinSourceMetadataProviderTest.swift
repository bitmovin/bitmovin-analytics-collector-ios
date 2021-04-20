import XCTest
import BitmovinPlayer

@testable import BitmovinAnalyticsCollector

class BitmovinSourceMetadataProviderTest: XCTestCase {
   
    private var sourceProvider: BitmovinSourceMetadataProvider = BitmovinSourceMetadataProvider()
    public let redbull: String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    
    func test_add_and_get_should_add_and_retreive_correct_source_metadata_reference(){
        //arrange
        
        let testURL = URL(string: redbull)!
        let playerSource = SourceFactory.create(from: SourceConfig(url: testURL)!)
        let expectedSourceMetadata = BitmovinSourceMetadata(playerSource: playerSource, videoId: "test")
        
        //act
        sourceProvider.add(sourceMetadata: expectedSourceMetadata)
        let sourceMetadata = sourceProvider.get(playerSource: playerSource)
        
        //assert
        XCTAssertTrue(expectedSourceMetadata == sourceMetadata)
    }
}
