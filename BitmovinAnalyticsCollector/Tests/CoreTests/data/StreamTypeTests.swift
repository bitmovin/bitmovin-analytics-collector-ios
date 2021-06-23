import XCTest
@testable import BitmovinAnalyticsCollector

class StreamTypeTests: XCTestCase {
    
    let streamTypeTests: Array<(name: String, streamUrl: String, expectedStreamType: StreamType)> = [
        (name: "Test HLS input with queryParams",
         streamUrl: "https://demo-hls5-live.zahs.tv/fullhd/master.m3u8?timeshift=100",
         expectedStreamType: StreamType.hls),
        
        (name: "Test HLS input without queryParams",
         streamUrl: "https://epixhls.akamaized.net/movies/v2/bill-and-ted-face-the-music/fc67eab0-e19a-494e-a152-75dbb469859e/playlist_720.m3u8",
         expectedStreamType: StreamType.hls),
        
        (name: "Test Dash input with queryParams",
         streamUrl: "https://demo-dash-live.zahs.tv/dolby/manifest.mpd?audio_codecs=aac,eac3",
         expectedStreamType: StreamType.dash),
        
        (name: "Test Dash input without queryParams",
         streamUrl: "https://demo-dash-live.zahs.tv/dolby/manifest.mpd",
         expectedStreamType: StreamType.dash)
    ]
    
    func test_streamType(){
        for test in streamTypeTests {
            let streamType = Util.streamType(from: test.streamUrl)
            XCTAssertEqual(streamType, test.expectedStreamType, "Test: \(test.name) failed! Expected \(test.expectedStreamType), got \(streamType)")
        }
    }
}
