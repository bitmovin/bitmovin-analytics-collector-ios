import BitmovinPlayer

@objc
@objcMembers
public class BitmovinSourceMetadata: SourceMetadata {
    @objc public init(playerSource: Source, videoId: String? = nil, title: String? = nil, path: String? = nil, isLive: Bool = false, mpdUrl: String? = nil, m3u8Url: String? = nil, cdnProvider: String? = nil, customData1: String? = nil, customData2: String? = nil, customData3: String? = nil, customData4: String? = nil, customData5: String? = nil, customData6: String? = nil, customData7: String? = nil, experimentName: String? = nil) {
        self.playerSource = playerSource
        super.init(videoId: videoId,
                   title: title,
                   path: path,
                   isLive: isLive,
                   mpdUrl: mpdUrl,
                   m3u8Url: m3u8Url,
                   cdnProvider: cdnProvider,
                   customData1: customData1,
                   customData2: customData2,
                   customData3: customData3,
                   customData4: customData4,
                   customData5: customData5,
                   customData6: customData6,
                   customData7: customData7,
                   experimentName: experimentName)
    }
    
    var playerSource: Source
    
    
}
