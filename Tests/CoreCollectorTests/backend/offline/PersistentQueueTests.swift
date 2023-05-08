import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class PersistentQueueTests: AsyncSpec {
    override class func spec() {
        var persistentQueue: PersistentQueue<EventData>!
        var fileLocation: URL!
        let iterationsForPerformanceTest = 10_000

        beforeEach {
            fileLocation = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            persistentQueue = PersistentQueue(fileUrl: fileLocation)
            await persistentQueue.removeAll()
        }

        describe("read and write performance") {
            context("when adding \(iterationsForPerformanceTest) entries after each other to the queue") {
                it("takes less than 5 milliseconds on average to add a new entry") {
                    let executionTime = await PerformanceTestHelper.measure(
                        numberOfIterations: iterationsForPerformanceTest
                    ) {
                        await persistentQueue.add(entry: EventData(UUID().uuidString))
                    }

                    expect(executionTime).to(beLessThan(0.005))
                }
            }
        }
        describe("adding entries") {
            it("adds the entry to the end of the queue") {
                await persistentQueue.add(entry: EventData("1"))
                await persistentQueue.add(entry: EventData("2"))

                let first = await persistentQueue.removeFirst()
                let second = await persistentQueue.removeFirst()

                expect(first?.impressionId).to(equal("1"))
                expect(second?.impressionId).to(equal("2"))
            }
        }
        describe("removing entries") {
            context("when entries exist in the queue") {
                it("removes entries from the beginning of the queue") {
                    await persistentQueue.add(entry: EventData("1"))
                    await persistentQueue.add(entry: EventData("2"))

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
                    await persistentQueue.add(entry: EventData("1"))
                    await persistentQueue.add(entry: EventData("2"))
                    await persistentQueue.add(entry: EventData("3"))
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
                        await persistentQueue.add(entry: EventData(String(index)))
                    }

                    let count = await persistentQueue.count
                    expect(count).to(equal(expectedCount))
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
                        await persistentQueue.add(entry: EventData("1"))

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
                    await persistentQueue.add(entry: EventData("1"))
                    await persistentQueue.add(entry: EventData("2"))
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
    }
}
