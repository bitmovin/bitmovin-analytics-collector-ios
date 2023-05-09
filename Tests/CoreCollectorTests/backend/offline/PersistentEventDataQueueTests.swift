import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class PersistentEventDataQueueTests: AsyncSpec {
    override class func spec() {
        var persistentEventDataQueue: PersistentEventDataQueue!
        var eventDataQueue: PersistentQueue<EventData, EventDataKey>!
        var adEventDataQueue: PersistentQueue<AdEventData, EventDataKey>!

        beforeEach {
            let fileLocationEventData = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            let fileLocationAdEventData = FileManager.default.temporaryDirectory.appendingPathComponent("tests/adEventData.json")

            eventDataQueue = PersistentQueue<EventData, EventDataKey>(fileUrl: fileLocationEventData)
            await eventDataQueue.removeAll()

            adEventDataQueue = PersistentQueue<AdEventData, EventDataKey>(fileUrl: fileLocationAdEventData)
            await adEventDataQueue.removeAll()

            persistentEventDataQueue = PersistentEventDataQueue(
                eventDataQueue: eventDataQueue,
                adEventDataQueue: adEventDataQueue
            )
        }
        describe("adding entries") {
            context("when database needs no cleanup") {
                it("adds each entry within 5 milliseconds") {
                    let executionTime = await PerformanceTestHelper.measure(
                        numberOfIterations: 100
                    ) {
                        await persistentEventDataQueue.add(EventData.random)
                    }

                    expect(executionTime).to(beLessThan(0.005))
                    let eventDataCount = await eventDataQueue.count
                    expect(eventDataCount).to(equal(100))
                }
                it("adds EventData to the queue") {
                    let eventData1 = EventData.random
                    let eventData2 = EventData.random

                    await persistentEventDataQueue.add(eventData1)
                    await persistentEventDataQueue.add(eventData2)

                    let count = await eventDataQueue.count
                    expect(count).to(equal(2))
                }
                it("adds AdEventData to the queue") {
                    let adEventData1 = AdEventData.random
                    let adEventData2 = AdEventData.random

                    await persistentEventDataQueue.addAd(adEventData1)
                    await persistentEventDataQueue.addAd(adEventData2)

                    let count = await adEventDataQueue.count
                    expect(count).to(equal(2))
                }
            }
            context("when database needs cleanup") {
                let entryCount = 5_000

                context("with a database containing \(entryCount) entries") {
                    context("and every entry is expired") {
                        beforeEach {
                            for _ in 0..<entryCount {
                                await eventDataQueue.add(EventData.old)
                            }
                        }
                        it("cleans up the whole database and adds the new entry within 500 milliseconds") {
                            let executionTime = await PerformanceTestHelper.measure(
                                numberOfIterations: 1
                            ) {
                                await persistentEventDataQueue.add(EventData.random)
                            }

                            expect(executionTime).to(beLessThan(0.5))
                            let eventDataCount = await eventDataQueue.count
                            expect(eventDataCount).to(equal(1))
                        }
                    }
                    context("and no entry is expired") {
                        beforeEach {
                            for _ in 0..<entryCount {
                                await eventDataQueue.add(EventData.random)
                            }
                        }
                        it("cleans up the whole database and adds the new entry within 500 milliseconds") {
                            let executionTime = await PerformanceTestHelper.measure(
                                numberOfIterations: 1
                            ) {
                                await persistentEventDataQueue.add(EventData.random)
                            }

                            expect(executionTime).to(beLessThan(0.5))
                            let eventDataCount = await eventDataQueue.count
                            expect(eventDataCount).to(equal(entryCount))
                        }
                    }
                }
            }
        }
        describe("removing entries") {
            context("when database needs no cleanup") {
                context("and database has 100 entries") {
                    beforeEach {
                        for _ in 0..<100 {
                            await eventDataQueue.add(EventData.random)
                        }
                    }
                    it("removes each entry within 5 milliseconds") {
                        let executionTime = await PerformanceTestHelper.measure(
                            numberOfIterations: 100
                        ) {
                            let entry = await persistentEventDataQueue.removeFirst()
                            expect(entry).toNot(beNil())
                        }

                        expect(executionTime).to(beLessThan(0.005))
                        let eventDataCount = await eventDataQueue.count
                        expect(eventDataCount).to(equal(0))
                    }
                }
                context("and database has two EventData entries") {
                    var eventData1: EventData!
                    var eventData2: EventData!

                    beforeEach {
                        eventData1 = EventData.random
                        eventData2 = EventData.random

                        await persistentEventDataQueue.add(eventData1)
                        await persistentEventDataQueue.add(eventData2)
                    }
                    it("removes EventData entries in the correct order") {
                        let first = await persistentEventDataQueue.removeFirst()
                        let second = await persistentEventDataQueue.removeFirst()
                        let third = await persistentEventDataQueue.removeFirst()

                        expect(first?.impressionId).to(equal(eventData1.impressionId))
                        expect(second?.impressionId).to(equal(eventData2.impressionId))
                        expect(third).to(beNil())
                    }
                }
                context("and database has two AdEventData entries") {
                    var adEventData1: AdEventData!
                    var adEventData2: AdEventData!

                    beforeEach {
                        adEventData1 = AdEventData.random
                        adEventData2 = AdEventData.random

                        await persistentEventDataQueue.addAd(adEventData1)
                        await persistentEventDataQueue.addAd(adEventData2)
                    }
                    it("removes AdEventData entries in the correct order") {
                        let first = await persistentEventDataQueue.removeFirstAd()
                        let second = await persistentEventDataQueue.removeFirstAd()
                        let third = await persistentEventDataQueue.removeFirstAd()

                        expect(first?.videoImpressionId).to(equal(adEventData1.videoImpressionId))
                        expect(second?.videoImpressionId).to(equal(adEventData2.videoImpressionId))
                        expect(third).to(beNil())
                    }
                }
            }
            context("when database needs cleanup") {
                let entryCount = 5_000
                var expectedEntry: EventData!

                beforeEach {
                    expectedEntry = EventData.random
                }
                context("with a database containing \(entryCount) entries") {
                    context("and every entry except for the last one is expired") {
                        beforeEach {
                            for _ in 0..<entryCount-1 {
                                await eventDataQueue.add(EventData.old)
                            }
                            await eventDataQueue.add(expectedEntry)
                        }
                        it("cleans up the whole database and returns the valid entry within 500 milliseconds") {
                            let executionTime = await PerformanceTestHelper.measure(
                                numberOfIterations: 1
                            ) {
                                let entry = await persistentEventDataQueue.removeFirst()
                                expect(entry?.impressionId).to(equal(expectedEntry.impressionId))
                            }

                            expect(executionTime).to(beLessThan(0.5))
                            let eventDataCount = await eventDataQueue.count
                            expect(eventDataCount).to(equal(0))
                        }
                    }
                }
            }
        }
    }
}
