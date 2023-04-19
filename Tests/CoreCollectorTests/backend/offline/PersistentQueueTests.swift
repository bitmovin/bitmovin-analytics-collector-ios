import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class PersistentQueueTests: QuickSpec {
    override func spec() {
        var persistentQueue: PersistentQueue<EventData>!
        var fileLocation: URL!
        let iterationsForPerformanceTest = 10_000

        beforeEach {
            fileLocation = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            persistentQueue = PersistentQueue(fileUrl: fileLocation)
            persistentQueue.removeAll()
        }

        describe("read and write performance") {
            context("when adding \(iterationsForPerformanceTest) entries after each other to the queue") {
                it("takes less than 5 milliseconds on average to add a new entry") {
                    let executionTime = PerformanceTestHelper.measure(
                        numberOfIterations: iterationsForPerformanceTest
                    ) {
                        persistentQueue.add(entry: EventData(UUID().uuidString))
                    }
                    
                    expect(executionTime).to(beLessThan(0.005))
                }
            }
        }
        describe("adding entries") {
            it("adds the entry to the end of the queue") {
                persistentQueue.add(entry: EventData("1"))
                persistentQueue.add(entry: EventData("2"))

                let first = persistentQueue.removeFirst()
                let second = persistentQueue.removeFirst()

                expect(first?.impressionId).to(equal("1"))
                expect(second?.impressionId).to(equal("2"))
            }
        }
        describe("removing entries") {
            context("when entries exist in the queue") {
                it("removes entries from the beginning of the queue") {
                    persistentQueue.add(entry: EventData("1"))
                    persistentQueue.add(entry: EventData("2"))

                    let first = persistentQueue.removeFirst()

                    expect(first?.impressionId).to(equal("1"))
                }
            }
            context("when no entries exist in the queue") {
                it("does not return an entry") {
                    let first = persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
            }
        }
        describe("removing all entries") {
            context("when entries exist in the queue") {
                beforeEach {
                    persistentQueue.add(entry: EventData("1"))
                    persistentQueue.add(entry: EventData("2"))
                    persistentQueue.add(entry: EventData("3"))
                }
                it("removes all entries") {
                    persistentQueue.removeAll()

                    let first = persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
            }
            context("when no entries exist in the queue") {
                it("keeps queue empty") {
                    persistentQueue.removeAll()

                    let first = persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
            }
        }
        describe("item count in queue") {
            context("for a queue with no entries") {
                it("returns 0") {
                    expect(persistentQueue.count).to(equal(0))
                }
            }
            context("for a queue with multiple entries") {
                it("returns correct value") {
                    let expectedCount = 10
                    (0..<expectedCount).forEach { index in
                        persistentQueue.add(entry: EventData(String(index)))
                    }

                    expect(persistentQueue.count).to(equal(expectedCount))
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
                    let first = persistentQueue.removeFirst()
                    expect(first).to(beNil())
                }
                context("and a new entry is added") {
                    it("is the only entry in the queue") {
                        persistentQueue.add(entry: EventData("1"))

                        let first = persistentQueue.removeFirst()
                        let second = persistentQueue.removeFirst()

                        expect(first?.impressionId).to(equal("1"))
                        expect(second).to(beNil())
                    }
                }
            }
            context("when file is not corrupted") {
                beforeEach {
                    persistentQueue.add(entry: EventData("1"))
                    persistentQueue.add(entry: EventData("2"))
                    persistentQueue = PersistentQueue(fileUrl: fileLocation)
                }
                it("uses the existing queue") {
                    let first = persistentQueue.removeFirst()
                    let second = persistentQueue.removeFirst()
                    let third = persistentQueue.removeFirst()

                    expect(first?.impressionId).to(equal("1"))
                    expect(second?.impressionId).to(equal("2"))
                    expect(third).to(beNil())
                }
            }
        }
    }
}
