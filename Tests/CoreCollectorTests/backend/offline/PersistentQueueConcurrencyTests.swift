@testable import CoreCollector
import Foundation
import Nimble
import Quick

class PersistentQueueConcurrencyTests: AsyncSpec {
    override class func spec() {
        var queue: PersistentQueue<EventData, EventDataKey>!
        var fileLocation: URL!
        let numberOfTasks = 10
        let entriesPerTask = 100

        beforeEach {
            fileLocation = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            queue = PersistentQueue<EventData, EventDataKey>(fileUrl: fileLocation)

            await queue.removeAll()
        }
        describe("adding entries") {
            context("when adding entries concurrently from \(numberOfTasks) tasks") {
                it("adds the correct amount of entries") {
                    let tasks = (0..<numberOfTasks).map { _ in
                        Task { [fileLocation] in
                            guard let fileLocation else { return }

                            let queue = PersistentQueue<EventData, EventDataKey>(fileUrl: fileLocation)
                            for _ in 0..<entriesPerTask {
                                await queue.add(EventData.random)
                            }
                        }
                    }

                    for task in tasks {
                        let _ = await task.value
                    }

                    let count = await queue.count
                    expect(count).to(equal(numberOfTasks * entriesPerTask))
                }
            }
        }
        describe("removing entries") {
            beforeEach {
                for _ in 0..<numberOfTasks * entriesPerTask {
                    await queue.add(EventData.random)
                }
            }
            context("when removing entries concurrently from \(numberOfTasks) tasks") {
                it("removes the correct amount of entries") {
                    let tasks = (0..<numberOfTasks).map { _ in
                        Task { [fileLocation] in
                            guard let fileLocation else { return }

                            let queue = PersistentQueue<EventData, EventDataKey>(fileUrl: fileLocation)
                            for _ in 0..<entriesPerTask {
                                let removed = await queue.removeFirst()

                                expect(removed).toNot(beNil())
                            }
                        }
                    }

                    for task in tasks {
                        let _ = await task.value
                    }

                    let count = await queue.count
                    expect(count).to(equal(.zero))
                }
            }
        }
    }
}
