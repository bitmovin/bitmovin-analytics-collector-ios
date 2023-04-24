import Nimble
import Quick
import UIKit
@testable import CoreCollector

class EventDataFactoryTests: QuickSpec {
    override func spec() {
        describe("createEventData") {
            it("should return EventData with basic data set") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.version).to(equal(UIDevice.current.systemVersion))
                expect(eventData.domain).to(equal(Util.mainBundleIdentifier()))
                expect(eventData.analyticsVersion).to(equal(Util.version()))
                expect(eventData.language).to(equal(DeviceInformationUtils.language()))
                expect(eventData.userAgent).to(equal(DeviceInformationUtils.userAgent()))
                expect(eventData.deviceInformation).notTo(beNil())
            }
            it("should return eventdata with analytics version set") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.analyticsVersion).notTo(beNil())
            }
            it("should return eventdata with config data set") {
                // arrange
                let config = self.getTestBitmovinConfig()
                let eventDataFactory = self.createDefaultEventDataFactoryForTest(config: config)

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.key).to(equal(config.key))
                expect(eventData.playerKey).to(equal(config.playerKey))
                expect(eventData.customUserId).notTo(beNil())

                expect(eventData.cdnProvider).to(equal(config.cdnProvider))
                expect(eventData.customData1).to(equal(config.customData1))
                expect(eventData.customData2).to(equal(config.customData2))
                expect(eventData.customData3).to(equal(config.customData3))
                expect(eventData.customData4).to(equal(config.customData4))
                expect(eventData.customData5).to(equal(config.customData5))
                expect(eventData.customData6).to(equal(config.customData6))
                expect(eventData.customData7).to(equal(config.customData7))
                expect(eventData.customData8).to(equal(config.customData8))
                expect(eventData.customData9).to(equal(config.customData9))
                expect(eventData.customData10).to(equal(config.customData10))
                expect(eventData.customData11).to(equal(config.customData11))
                expect(eventData.customData12).to(equal(config.customData12))
                expect(eventData.customData13).to(equal(config.customData13))
                expect(eventData.customData14).to(equal(config.customData14))
                expect(eventData.customData15).to(equal(config.customData15))
                expect(eventData.customData16).to(equal(config.customData16))
                expect(eventData.customData17).to(equal(config.customData17))
                expect(eventData.customData18).to(equal(config.customData18))
                expect(eventData.customData19).to(equal(config.customData19))
                expect(eventData.customData20).to(equal(config.customData20))
                expect(eventData.customData21).to(equal(config.customData21))
                expect(eventData.customData22).to(equal(config.customData22))
                expect(eventData.customData23).to(equal(config.customData23))
                expect(eventData.customData24).to(equal(config.customData24))
                expect(eventData.customData25).to(equal(config.customData25))
                expect(eventData.customData26).to(equal(config.customData26))
                expect(eventData.customData27).to(equal(config.customData27))
                expect(eventData.customData28).to(equal(config.customData28))
                expect(eventData.customData29).to(equal(config.customData29))
                expect(eventData.customData30).to(equal(config.customData30))
                expect(eventData.videoId).to(equal(config.videoId))
                expect(eventData.videoTitle).to(equal(config.title))
                expect(eventData.experimentName).to(equal(config.experimentName))
                expect(eventData.path).to(equal(config.path))
            }
            it("should return eventdata with sourceMetaData set") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()
                let currentSourceMetadata = SourceMetadata(
                    videoId: "test-video-id-sourceMetadata",
                    title: "test-title-sourceMetadata",
                    path: "test-path-sourceMetadata",
                    cdnProvider: "test-custom_cdn_provider-sourceMetadata",
                    customData1: "test-customData1-sourceMetadata",
                    customData2: "test-customData2-sourceMetadata",
                    customData3: "test-customData3-sourceMetadata",
                    customData4: "test-customData4-sourceMetadata",
                    customData5: "test-customData5-sourceMetadata",
                    customData6: "test-customData6-sourceMetadata",
                    customData7: "test-customData7-sourceMetadata",
                    customData8: "test-customData8-sourceMetadata",
                    customData9: "test-customData9-sourceMetadata",
                    customData10: "test-customData10-sourceMetadata",
                    customData11: "test-customData11-sourceMetadata",
                    customData12: "test-customData12-sourceMetadata",
                    customData13: "test-customData13-sourceMetadata",
                    customData14: "test-customData14-sourceMetadata",
                    customData15: "test-customData15-sourceMetadata",
                    customData16: "test-customData16-sourceMetadata",
                    customData17: "test-customData17-sourceMetadata",
                    customData18: "test-customData18-sourceMetadata",
                    customData19: "test-customData19-sourceMetadata",
                    customData20: "test-customData20-sourceMetadata",
                    customData21: "test-customData21-sourceMetadata",
                    customData22: "test-customData22-sourceMetadata",
                    customData23: "test-customData23-sourceMetadata",
                    customData24: "test-customData24-sourceMetadata",
                    customData25: "test-customData25-sourceMetadata",
                    customData26: "test-customData26-sourceMetadata",
                    customData27: "test-customData27-sourceMetadata",
                    customData28: "test-customData28-sourceMetadata",
                    customData29: "test-customData29-sourceMetadata",
                    customData30: "test-customData30-sourceMetadata",
                    experimentName: "test-experiment-sourceMetadata"
                )

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    Util.timeIntervalToCMTime(_: 0),
                    Util.timeIntervalToCMTime(_: 10),
                    60,
                    currentSourceMetadata
                )

                // arrange
                expect(eventData.cdnProvider).to(equal(currentSourceMetadata.cdnProvider))
                expect(eventData.customData1).to(equal(currentSourceMetadata.customData1))
                expect(eventData.customData2).to(equal(currentSourceMetadata.customData2))
                expect(eventData.customData3).to(equal(currentSourceMetadata.customData3))
                expect(eventData.customData4).to(equal(currentSourceMetadata.customData4))
                expect(eventData.customData5).to(equal(currentSourceMetadata.customData5))
                expect(eventData.customData6).to(equal(currentSourceMetadata.customData6))
                expect(eventData.customData7).to(equal(currentSourceMetadata.customData7))
                expect(eventData.customData8).to(equal(currentSourceMetadata.customData8))
                expect(eventData.customData9).to(equal(currentSourceMetadata.customData9))
                expect(eventData.customData10).to(equal(currentSourceMetadata.customData10))
                expect(eventData.customData11).to(equal(currentSourceMetadata.customData11))
                expect(eventData.customData12).to(equal(currentSourceMetadata.customData12))
                expect(eventData.customData13).to(equal(currentSourceMetadata.customData13))
                expect(eventData.customData14).to(equal(currentSourceMetadata.customData14))
                expect(eventData.customData15).to(equal(currentSourceMetadata.customData15))
                expect(eventData.customData16).to(equal(currentSourceMetadata.customData16))
                expect(eventData.customData17).to(equal(currentSourceMetadata.customData17))
                expect(eventData.customData18).to(equal(currentSourceMetadata.customData18))
                expect(eventData.customData19).to(equal(currentSourceMetadata.customData19))
                expect(eventData.customData20).to(equal(currentSourceMetadata.customData20))
                expect(eventData.customData21).to(equal(currentSourceMetadata.customData21))
                expect(eventData.customData22).to(equal(currentSourceMetadata.customData22))
                expect(eventData.customData23).to(equal(currentSourceMetadata.customData23))
                expect(eventData.customData24).to(equal(currentSourceMetadata.customData24))
                expect(eventData.customData25).to(equal(currentSourceMetadata.customData25))
                expect(eventData.customData26).to(equal(currentSourceMetadata.customData26))
                expect(eventData.customData27).to(equal(currentSourceMetadata.customData27))
                expect(eventData.customData28).to(equal(currentSourceMetadata.customData28))
                expect(eventData.customData29).to(equal(currentSourceMetadata.customData29))
                expect(eventData.customData30).to(equal(currentSourceMetadata.customData30))
                expect(eventData.videoId).to(equal(currentSourceMetadata.videoId))
                expect(eventData.videoTitle).to(equal(currentSourceMetadata.title))
                expect(eventData.experimentName).to(equal(currentSourceMetadata.experimentName))
                expect(eventData.path).to(equal(currentSourceMetadata.path))
            }
            it("should return eventdata with parameter set") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    Util.timeIntervalToCMTime(_: 0),
                    Util.timeIntervalToCMTime(_: 10),
                    60,
                    nil
                )

                // arrange
                expect(eventData.state).to(equal("test-state"))
                expect(eventData.impressionId).to(equal("test-impression"))
                expect(eventData.videoTimeStart).to(equal(0))
                expect(eventData.videoTimeEnd).to(equal(10_000))
                expect(eventData.drmLoadTime).to(equal(60))
            }
            it("should return eventdata with userId") {
                // arrange
                let mockUserIdProvider = MockUserIdProvider()
                mockUserIdProvider.setActionForGetUserId {
                    "user-Id"
                }
                let eventDataFactory = self.createDefaultEventDataFactoryForTest(userIdProvider: mockUserIdProvider)

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.userId).to(equal("user-Id"))
            }
            it("should return eventdata with increasing sequence number") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )
                let eventData2 = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.sequenceNumber).to(equal(0))
                expect(eventData2.sequenceNumber).to(equal(1))
            }
        }
        describe("reset") {
            it("should reset the sequence number") {
                // arrange
                let eventDataFactory = self.createDefaultEventDataFactoryForTest()

                // act
                let eventData = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )
                let eventData2 = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )
                eventDataFactory.reset()

                let eventData3 = eventDataFactory.createEventData(
                    "test-state",
                    "test-impression",
                    nil,
                    nil,
                    nil,
                    nil
                )

                // arrange
                expect(eventData.sequenceNumber).to(equal(0))
                expect(eventData2.sequenceNumber).to(equal(1))
                expect(eventData3.sequenceNumber).to(equal(0))
            }
        }
    }

    private func createDefaultEventDataFactoryForTest(
        config: BitmovinAnalyticsConfig? = nil,
        userIdProvider: UserIdProvider? = nil
    ) -> EventDataFactory {
        let conf = config ?? getTestBitmovinConfig()
        let userProv = userIdProvider ?? RandomizedUserIdProvider()
        return EventDataFactory(conf, userProv)
    }

    private func getTestBitmovinConfig() -> BitmovinAnalyticsConfig {
        let config = BitmovinAnalyticsConfig(key: "analytics-key", playerKey: "player-key")
        config.customerUserId = "test-customer-user-id"
        config.cdnProvider = "test-custom_cdn_provider"
        config.customData1 = "test-customData1"
        config.customData2 = "test-customData2"
        config.customData3 = "test-customData3"
        config.customData4 = "test-customData4"
        config.customData5 = "test-customData5"
        config.customData6 = "test-customData6"
        config.customData7 = "test-customData7"
        config.customData8 = "test-customData8"
        config.customData9 = "test-customData9"
        config.customData10 = "test-customData10"
        config.customData11 = "test-customData11"
        config.customData12 = "test-customData12"
        config.customData13 = "test-customData13"
        config.customData14 = "test-customData14"
        config.customData15 = "test-customData15"
        config.customData16 = "test-customData16"
        config.customData17 = "test-customData17"
        config.customData18 = "test-customData18"
        config.customData19 = "test-customData19"
        config.customData20 = "test-customData20"
        config.customData21 = "test-customData21"
        config.customData22 = "test-customData22"
        config.customData23 = "test-customData23"
        config.customData24 = "test-customData24"
        config.customData25 = "test-customData25"
        config.customData26 = "test-customData26"
        config.customData27 = "test-customData27"
        config.customData28 = "test-customData28"
        config.customData29 = "test-customData29"
        config.customData30 = "test-customData30"
        config.experimentName = "test-experiment"
        config.videoId = "test-video-id"
        config.title = "test-title"
        config.path = "test-path"
        return config
    }
}
