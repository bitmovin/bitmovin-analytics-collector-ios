import XCTest

#if !SWIFT_PACKAGE
@testable import BitmovinAnalyticsCollector
#endif

#if SWIFT_PACKAGE
@testable import CoreCollector
#endif

class EventDataTests: XCTestCase {
    func testSerializesCorrectly() throws {
        // Arrange
        let impressionId = "097170EB-51BA-435F-9F6F-727896EBEB45"

        let eventData = EventData(impressionId)
        eventData.domain = "testDomain"
        eventData.path = "testPath"
        eventData.language = "en_US"
        eventData.userAgent = "testUserAgent"
        eventData.deviceInformation = DeviceInformationDto(
            manufacturer: "Apple",
            model: "iPhone",
            isTV: false,
            operatingSystem: "iOS",
            operatingSystemMajorVersion: "15",
            operatingSystemMinorVersion: "2",
            deviceClass: DeviceClass.phone,
            screenHeight: 123,
            screenWidth: 321
        )
        eventData.errorCode = 1_000
        eventData.errorMessage = "testErrorMessage"
        eventData.screenWidth = 420
        eventData.screenHeight = 720
        eventData.isLive = true
        eventData.isCasting = false
        eventData.castTech = "chromecast"
        eventData.isMuted = true
        eventData.videoDuration = 10_000
        eventData.time = 100
        eventData.videoWindowWidth = 71
        eventData.videoWindowHeight = 72
        eventData.droppedFrames = 3
        eventData.played = 40
        eventData.buffered = 50
        eventData.paused = 89
        eventData.ad = 34
        eventData.seeked = 22
        eventData.videoPlaybackWidth = 61
        eventData.videoPlaybackHeight = 62
        eventData.videoBitrate = 48_000
        eventData.audioBitrate = 56_000
        eventData.videoTimeEnd = 4
        eventData.videoTimeStart = 3
        eventData.videoStartupTime = 11
        eventData.duration = 555
        eventData.startupTime = 12
        eventData.analyticsVersion = "v1.0.0"
        eventData.key = "79D9DC63-1F50-4147-A9A4-60CC3A14C240"
        eventData.playerKey = "8EE37653-F163-44F1-ADA8-2EED286A320E"
        eventData.player = "bitmovin"
        eventData.playerTech = "native"
        eventData.cdnProvider = "AKAMAI"
        eventData.streamFormat = "dash"
        eventData.videoId = "testVideoId"
        eventData.videoTitle = "testVideoTitle"
        eventData.customUserId = "customUserId"
        eventData.customData1 = "customData1"
        eventData.customData2 = "customData2"
        eventData.customData3 = "customData3"
        eventData.customData4 = "customData4"
        eventData.customData5 = "customData5"
        eventData.customData6 = "customData6"
        eventData.customData7 = "customData7"
        eventData.customData8 = "customData8"
        eventData.customData9 = "customData9"
        eventData.customData10 = "customData10"
        eventData.customData11 = "customData11"
        eventData.customData12 = "customData12"
        eventData.customData13 = "customData13"
        eventData.customData14 = "customData14"
        eventData.customData15 = "customData15"
        eventData.customData16 = "customData16"
        eventData.customData17 = "customData17"
        eventData.customData18 = "customData18"
        eventData.customData19 = "customData19"
        eventData.customData20 = "customData20"
        eventData.customData21 = "customData21"
        eventData.customData22 = "customData22"
        eventData.customData23 = "customData23"
        eventData.customData24 = "customData24"
        eventData.customData25 = "customData25"
        eventData.customData26 = "customData26"
        eventData.customData27 = "customData27"
        eventData.customData28 = "customData28"
        eventData.customData29 = "customData29"
        eventData.customData30 = "customData30"
        eventData.experimentName = "experimentName"
        eventData.userId = "testUserId"
        eventData.state = "state"
        eventData.m3u8Url = "m3u8Url"
        eventData.mpdUrl = "mpdUrl"
        eventData.progUrl = "progUrl"
        eventData.playerStartupTime = 24
        eventData.pageLoadTime = 0
        eventData.version = "version"
        eventData.sequenceNumber = 0
        eventData.drmType = "fairplay"
        eventData.drmLoadTime = 1
        eventData.videoCodec = "av1"
        eventData.audioCodec = "mp3"
        eventData.supportedVideoCodecs = ["av1"]
        eventData.subtitleEnabled = true
        eventData.subtitleLanguage = "en_US"
        eventData.audioLanguage = "de_DE"
        eventData.videoStartFailed = true
        eventData.videoStartFailedReason = "SESSION_TIMEOUT"

        let expectedJsonString = """
        {"ad":34,"analyticsVersion":"v1.0.0","audioBitrate":56000,"audioCodec":"mp3","audioLanguage":"de_DE","buffered":50,"castTech":"chromecast","cdnProvider":"AKAMAI","customData1":"customData1","customData2":"customData2","customData3":"customData3","customData4":"customData4","customData5":"customData5","customData6":"customData6","customData7":"customData7","customData8":"customData8","customData9":"customData9","customData10":"customData10","customData11":"customData11","customData12":"customData12","customData13":"customData13","customData14":"customData14","customData15":"customData15","customData16":"customData16","customData17":"customData17","customData18":"customData18","customData19":"customData19","customData20":"customData20","customData21":"customData21","customData22":"customData22","customData23":"customData23","customData24":"customData24","customData25":"customData25","customData26":"customData26","customData27":"customData27","customData28":"customData28","customData29":"customData29","customData30":"customData30","customUserId":"customUserId","deviceInformation":{"deviceClass":"Phone","isTV":false,"manufacturer":"Apple","model":"iPhone","operatingSystem":"iOS","operatingSystemMajor":"15","operatingSystemMinor":"2","screenHeight":123,"screenWidth":321},"domain":"testDomain","drmLoadTime":1,"drmType":"fairplay","droppedFrames":3,"duration":555,"errorCode":1000,"errorMessage":"testErrorMessage","experimentName":"experimentName","impressionId":"097170EB-51BA-435F-9F6F-727896EBEB45","isCasting":false,"isLive":true,"isMuted":true,"key":"79D9DC63-1F50-4147-A9A4-60CC3A14C240","language":"en_US","m3u8Url":"m3u8Url","mpdUrl":"mpdUrl","pageLoadTime":0,"pageLoadType":1,"path":"testPath","paused":89,"platform":"iOS","played":40,"player":"bitmovin","playerKey":"8EE37653-F163-44F1-ADA8-2EED286A320E","playerStartupTime":24,"playerTech":"native","progUrl":"progUrl","screenHeight":720,"screenWidth":420,"seeked":22,"sequenceNumber":0,"startupTime":12,"state":"state","streamFormat":"dash","subtitleEnabled":true,"subtitleLanguage":"en_US","supportedVideoCodecs":["av1"],"time":100,"userAgent":"testUserAgent","userId":"testUserId","version":"version","videoBitrate":48000,"videoCodec":"av1","videoDuration":10000,"videoId":"testVideoId","videoPlaybackHeight":62,"videoPlaybackWidth":61,"videoStartFailed":true,"videoStartFailedReason":"SESSION_TIMEOUT","videoStartupTime":11,"videoTimeEnd":4,"videoTimeStart":3,"videoTitle":"testVideoTitle","videoWindowHeight":72,"videoWindowWidth":71}
        """

        // Act
        let jsonString = eventData.jsonString()

        // Assert
        XCTAssertEqual(jsonString, expectedJsonString)
    }
}
