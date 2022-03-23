import Foundation

public class EventData: Codable {
    public var domain: String?
    public var path: String?
    public var language: String?
    public var userAgent: String?
    public var deviceInformation: DeviceInformationDto?
    public var errorCode: Int?
    public var errorMessage: String?
    public var errorData: String?
    public var screenWidth: Int?
    public var screenHeight: Int?
    public var isLive: Bool = false
    public var isCasting: Bool? = false
    public var castTech: String?
    public var isMuted: Bool? = false
    public var videoDuration: Int64 = 0
    public var time: Double?
    public var videoWindowWidth: Int = 0
    public var videoWindowHeight: Int = 0
    public var droppedFrames: Int = 0
    public var played: Int64 = 0
    public var buffered: Int64 = 0
    public var paused: Int64 = 0
    public var ad: Int64 = 0
    public var seeked: Int64 = 0
    public var videoPlaybackWidth: Int?
    public var videoPlaybackHeight: Int?
    public var videoBitrate: Double = 0
    public var audioBitrate: Double = 0
    public var videoTimeStart: Int64 = 0
    public var videoTimeEnd: Int64 = 0
    public var videoStartupTime: Int64 = 0
    public var duration: Int64 = 0
    public var startupTime: Int64 = 0
    public var analyticsVersion: String = "0"
    public var key: String?
    public var playerKey: String?
    public var player: String?
    public var playerTech: String?
    public var cdnProvider: String?
    public var streamFormat: String?
    public var videoId: String?
    public var videoTitle: String?
    public var customUserId: String?
    public var customData1: String?
    public var customData2: String?
    public var customData3: String?
    public var customData4: String?
    public var customData5: String?
    public var customData6: String?
    public var customData7: String?
    public var customData8: String?
    public var customData9: String?
    public var customData10: String?
    public var customData11: String?
    public var customData12: String?
    public var customData13: String?
    public var customData14: String?
    public var customData15: String?
    public var customData16: String?
    public var customData17: String?
    public var customData18: String?
    public var customData19: String?
    public var customData20: String?
    public var customData21: String?
    public var customData22: String?
    public var customData23: String?
    public var customData24: String?
    public var customData25: String?
    public var customData26: String?
    public var customData27: String?
    public var customData28: String?
    public var customData29: String?
    public var customData30: String?
    public var experimentName: String?
    public var userId: String?
    public var impressionId: String
    public var state: String?
    public var m3u8Url: String?
    public var mpdUrl: String?
    public var progUrl: String?
    public var playerStartupTime: Int64 = 0
    public var pageLoadType: Int = 1
    public var pageLoadTime: Int64 = 0
    public var version: String?
    public var sequenceNumber: Int32 = 0
    public var drmType: String?
    public var drmLoadTime: Int64?
    public var platform: String
    public var videoCodec: String?
    public var audioCodec: String?
    public var supportedVideoCodecs: [String]?
    public var subtitleEnabled: Bool?
    public var subtitleLanguage: String?
    public var audioLanguage: String?
    public var videoStartFailed: Bool?
    public var videoStartFailedReason: String?

    init(_ impressionId: String) {
        self.impressionId = impressionId

        #if os(iOS)
        self.platform = "iOS"
        #elseif os(tvOS)
        self.platform = "tvOS"
        #elseif os(watchOS)
        self.platform = "watchOS"
        #elseif os(macOS)
        self.platform = "macOS"
        #elseif os(Linux)
        self.platform = "Linux"
        #else
        self.platform = "unknown"
        #endif
    }
    
    public func jsonString() -> String {
        let encoder = JSONEncoder()
        if #available(iOS 11.0, tvOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }

        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
        do {
            let jsonData = try encoder.encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }

            return jsonString
        } catch {
            return ""
        }
    }
}
