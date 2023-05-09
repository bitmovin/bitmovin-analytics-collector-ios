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

                    print("XXX execution time for adding: \(executionTime)")
                    expect(executionTime).to(beLessThan(0.005))
                    let eventDataCount = await eventDataQueue.count
                    expect(eventDataCount).to(equal(100))
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

                            print("XXX execution time for adding with cleanup: \(executionTime)")
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

                            print("XXX execution time for adding with cleanup but no expired entries: \(executionTime)")
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

                    print("XXX execution time for removing: \(executionTime)")
                    expect(executionTime).to(beLessThan(0.005))
                    let eventDataCount = await eventDataQueue.count
                    expect(eventDataCount).to(equal(0))
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

                            print("XXX execution time for removing with cleanup: \(executionTime)")
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
