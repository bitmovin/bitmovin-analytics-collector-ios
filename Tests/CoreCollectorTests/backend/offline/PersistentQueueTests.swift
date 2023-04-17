import Cuckoo
import Nimble
import Quick

@testable import CoreCollector
import Foundation

class PersistentQueueTests: QuickSpec {
    override func spec() {
        var persistentQueue: PersistentQueue<EventData>!
        var fileLocation: URL!
        let iterationsForPerformanceTest = 500

        beforeEach {
            fileLocation = FileManager.default.temporaryDirectory.appendingPathComponent("tests/eventData.json")
            persistentQueue = PersistentQueue(fileUrl: fileLocation)
            persistentQueue.removeAll()
        }

        describe("read and write performance") {
            context("when adding \(iterationsForPerformanceTest) entries after each other") {
                it("takes less than 50 milliseconds on average to add a new entry") {
                    let executionTime = PerformanceTestHelper.measure(
                        numberOfIterations: iterationsForPerformanceTest
                    ) {
                        persistentQueue.add(entry: EventData(UUID().uuidString))
                    }
                    
                    expect(executionTime).to(beLessThan(0.05))
                }
            }
        }
    }
}
