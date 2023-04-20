import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class AuthenticatedDispatcherTests: QuickSpec {
    override class func spec() {
        var mockAuthService = MockAuthenticationService()
        var mockInnerDispatcher = MockEventDataDispatcher()
        var mockNotificationCenter = NotificationCenter()
        var dispatcher = AuthenticatedDispatcher(
            authenticationService: mockAuthService,
            notificationCenter: mockNotificationCenter,
            innerDispatcher: mockInnerDispatcher
        )
        beforeEach {
            mockAuthService = MockAuthenticationService()
            mockInnerDispatcher = MockEventDataDispatcher()
            mockNotificationCenter = NotificationCenter()
            dispatcher = AuthenticatedDispatcher(
                authenticationService: mockAuthService,
                notificationCenter: mockNotificationCenter,
                innerDispatcher: mockInnerDispatcher
            )
        }
        describe("add") {
            it("should not interact with innerDispatcher when disabled") {
                // arrange
                let eventData = EventData("test-impression")

                // act
                dispatcher.add(eventData)

                // assert
                verifyNoMoreInteractions(mockInnerDispatcher)
            }
            it("should call innerDispatcher when enabled") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.add(any())).thenDoNothing()
                }
                let eventData = EventData("test-impression")
                // emit authentication success event
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // act
                dispatcher.add(eventData)

                // assert
                verify(mockInnerDispatcher).add(equal(to: eventData))
            }
        }
        describe("addAd") {
            it("should not interact with innerDispatcher when disabled") {
                // arrange
                let eventData = AdEventData()

                // act
                dispatcher.addAd(eventData)

                // assert
                verifyNoMoreInteractions(mockInnerDispatcher)
            }
            it("should call innerDispatcher when enabled") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.addAd(any())).thenDoNothing()
                }
                let eventData = AdEventData()
                // emit authentication success event
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // act
                dispatcher.addAd(eventData)

                // assert
                verify(mockInnerDispatcher).addAd(equal(to: eventData))
            }
        }
        describe("disable") {
            it("should call innerDispatcher") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.disable()).thenDoNothing()
                }

                // act
                dispatcher.disable()

                // assert
                verify(mockInnerDispatcher).disable()
            }
            it("should not call add and addAd on innerDispatcher when .disable was called") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.disable()).thenDoNothing()
                }

                let eventData = EventData("test-impression")
                let adEventData = AdEventData()

                // emit authentication success event
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // act
                dispatcher.disable()

                // assert
                verify(mockInnerDispatcher).disable()
                dispatcher.addAd(adEventData)
                dispatcher.add(eventData)
                verifyNoMoreInteractions(mockInnerDispatcher)
            }
        }
        describe("resetSourceState") {
            it("should call innerDispatcher") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.resetSourceState()).thenDoNothing()
                }

                // act
                dispatcher.resetSourceState()

                // assert
                verify(mockInnerDispatcher).resetSourceState()
            }
        }
        describe("authentication denied") {
            it("should call innerDispatcher") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.disable()).thenDoNothing()
                }

                // act
                mockNotificationCenter.post(name: .authenticationDenied, object: mockAuthService)

                // assert
                verify(mockInnerDispatcher).disable()
            }
            it("should not call add and addAd on innerDispatcher when authentication was denied") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.disable()).thenDoNothing()
                }

                let eventData = EventData("test-impression")
                let adEventData = AdEventData()

                // emit authentication success event
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // act
                mockNotificationCenter.post(name: .authenticationDenied, object: mockAuthService)

                // assert
                verify(mockInnerDispatcher).disable()
                dispatcher.addAd(adEventData)
                dispatcher.add(eventData)
                verifyNoMoreInteractions(mockInnerDispatcher)
            }
        }
        describe("authentication error") {
            // TODO: add tests
            // MARK: If offline analytics is enabled, we can continue otherwise it should be the same as .denied
        }
        describe("event flushing") {
            it("should not call innerDispatcher when queue is empty") {
                // arrange

                // act
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // assert
                verifyNoMoreInteractions(mockInnerDispatcher)
            }
            it("should call innerDispatcher when events are in queue") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.add(any())).thenDoNothing()
                    when(stub.addAd(any())).thenDoNothing()
                }

                let eventData = EventData("test-impression")
                let adEventData = AdEventData()

                dispatcher.add(eventData)
                dispatcher.addAd(adEventData)
                verifyNoMoreInteractions(mockInnerDispatcher)

                // act
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // assert
                verify(mockInnerDispatcher).add(equal(to:eventData))
                verify(mockInnerDispatcher).addAd(equal(to:adEventData))
            }
            it("should call innerDispatcher.add with correct order of events") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.add(any())).thenDoNothing()
                }

                let eventData1 = EventData("test-impression")
                eventData1.sequenceNumber = 1
                let eventData2 = EventData("test-impression")
                eventData2.sequenceNumber = 2

                dispatcher.add(eventData1)
                dispatcher.add(eventData2)
                verifyNoMoreInteractions(mockInnerDispatcher)

                // act
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // assert
                let captor = ArgumentCaptor<EventData>()
                verify(mockInnerDispatcher, times(2)).add(captor.capture())
                expect(captor.allValues.first?.jsonString()).to(equal(eventData1.jsonString()))
                expect(captor.allValues.last?.jsonString()).to(equal(eventData2.jsonString()))
            }

            it("should call innerDispatcher.addAd with correct order of events") {
                // arrange
                stub(mockInnerDispatcher) { stub in
                    when(stub.addAd(any())).thenDoNothing()
                }

                let eventData1 = AdEventData()
                eventData1.adId = "ad-1"
                let eventData2 = AdEventData()
                eventData2.adId = "ad-2"

                dispatcher.addAd(eventData1)
                dispatcher.addAd(eventData2)
                verifyNoMoreInteractions(mockInnerDispatcher)

                // act
                mockNotificationCenter.post(name: .authenticationSuccess, object: mockAuthService)

                // assert
                let captor = ArgumentCaptor<AdEventData>()
                verify(mockInnerDispatcher, times(2)).addAd(captor.capture())
                expect(Util.toJson(object: captor.allValues.first))
                    .to(equal(Util.toJson(object: eventData1)))
                expect(Util.toJson(object: captor.allValues.last))
                    .to(equal(Util.toJson(object: eventData2)))
            }
        }
    }
}
