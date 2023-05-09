import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class PersistentQueueTests: AsyncSpec {
    override class func spec() {
        var persistentQueue: PersistentQueue<EventData, EventDataKey>!
        var fileLocation: URL!

        beforeEach {
            fileLocation = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            persistentQueue = PersistentQueue(fileUrl: fileLocation)
            await persistentQueue.removeAll()
        }

        describe("read and write performance") {
            let entryCount = 5_000

            context("when adding \(entryCount) entries after each other to the queue") {
                it("takes less than 5 milliseconds on average to add a new entry") {
                    let executionTime = await PerformanceTestHelper.measure(
                        numberOfIterations: entryCount
                    ) {
                        await persistentQueue.add(EventData.random)
                    }

                    expect(executionTime).to(beLessThan(0.005))
                }
            }
        }
        describe("adding entries") {
            it("adds the entry to the end of the queue") {
                await persistentQueue.add(EventData("1"))
                await persistentQueue.add(EventData("2"))

                let first = await persistentQueue.removeFirst()
                let second = await persistentQueue.removeFirst()

                expect(first?.impressionId).to(equal("1"))
                expect(second?.impressionId).to(equal("2"))
            }
        }
        describe("removing entries") {
            context("when entries exist in the queue") {
                it("removes entries from the beginning of the queue") {
                    await persistentQueue.add(EventData("1"))
                    await persistentQueue.add(EventData("2"))

                    let first = await persistentQueue.removeFirst()

                    expect(first?.impressionId).to(equal("1"))
                }
            }
            context("when no entries exist in the queue") {
                it("does not return an entry") {
                    let first = await persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
            }
        }
        describe("removing all entries") {
            context("when entries exist in the queue") {
                beforeEach {
                    await persistentQueue.add(EventData("1"))
                    await persistentQueue.add(EventData("2"))
                    await persistentQueue.add(EventData("3"))
                }
                it("removes all entries") {
                    await persistentQueue.removeAll()

                    let count = await persistentQueue.count
                    expect(count).to(equal(.zero))
                }
            }
            context("when no entries exist in the queue") {
                it("keeps queue empty") {
                    await persistentQueue.removeAll()

                    let count = await persistentQueue.count
                    expect(count).to(equal(.zero))
                }
            }
        }
        describe("item count in queue") {
            context("for a queue with no entries") {
                it("returns 0") {
                    let count = await persistentQueue.count
                    expect(count).to(equal(0))
                }
            }
            context("for a queue with multiple entries") {
                it("returns correct value") {
                    let expectedCount = 10
                    for index in 0..<expectedCount {
                        await persistentQueue.add(EventData(String(index)))
                    }

                    let count = await persistentQueue.count
                    expect(count).to(equal(expectedCount))
                }
            }
            context("for a large queue") {
                let entryCount = 5_000

                beforeEach {
                    for _ in 0..<entryCount {
                        await persistentQueue.add(EventData.random)
                    }
                }
                it("returns correct value within 75 milliseconds") {
                    let executionTime = await PerformanceTestHelper.measure(
                        numberOfIterations: 10
                    ) {
                        let _ = await persistentQueue.count
                    }

                    expect(executionTime).to(beLessThan(0.075))
                }
            }
        }
        describe("database integrity") {
            context("when file is corrupted") {
                beforeEach {
                    try? "not a valid queue".write(to: fileLocation, atomically: true, encoding: .utf8)
                    persistentQueue = PersistentQueue(fileUrl: fileLocation)
                }
                it("creates an empty queue") {
                    let first = await persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
                context("and a new entry is added") {
                    it("is the only entry in the queue") {
                        await persistentQueue.add(EventData("1"))

                        let count = await persistentQueue.count
                        expect(count).to(equal(1))

                        let first = await persistentQueue.removeFirst()
                        let second = await persistentQueue.removeFirst()

                        expect(first?.impressionId).to(equal("1"))
                        expect(second).to(beNil())
                    }
                }
            }
            context("when file is not corrupted") {
                beforeEach {
                    await persistentQueue.add(EventData("1"))
                    await persistentQueue.add(EventData("2"))
                    persistentQueue = PersistentQueue(fileUrl: fileLocation)
                }
                it("uses the existing queue") {
                    let count = await persistentQueue.count
                    expect(count).to(equal(2))

                    let first = await persistentQueue.removeFirst()
                    let second = await persistentQueue.removeFirst()

                    expect(first?.impressionId).to(equal("1"))
                    expect(second?.impressionId).to(equal("2"))
                }
            }
        }
        describe("iterating the whole queue") {
            let entryCount = 5_000

            context("when the queue contains \(entryCount) entries") {
                beforeEach {
                    for _ in 0..<entryCount {
                        await persistentQueue.add(EventData.random)
                    }
                }
                it("takes less than 150 milliseconds on average to iterate the whole queue") {
                    let executionTime = await PerformanceTestHelper.measure(
                        numberOfIterations: 10
                    ) {
                        await persistentQueue.forEach { _ in }
                    }

                    expect(executionTime).to(beLessThan(0.15))
                }
            }
        }
    }
}

// TODO: move to general place and improve implementation
extension EventData {
    static var random: EventData {
        let eventData = EventData(UUID().uuidString)
        eventData.audioBitrate = 1000
        eventData.videoCodec = "HEVC"
        eventData.audioLanguage = "de"
        eventData.videoTitle = "Lorem ipsum dolor"
        eventData.cdnProvider = "Akamai"
        eventData.domain = "com.bitmovin.player"
        eventData.time = Date().timeIntervalSince1970Millis

        return eventData
    }

    static var old: EventData {
        let eventData = EventData.random
        eventData.time = 0

        return eventData
    }
}
