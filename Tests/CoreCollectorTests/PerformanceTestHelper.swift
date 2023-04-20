import Foundation
import XCTest

public class PerformanceTestHelper {
    /// Measures performance of `actionBlock`
    /// - Parameters:
    ///   - numberOfIterations: number of iterations to run
    ///   - actionBlock: closure to test for execution time
    /// - Returns: average execution time per iteration
    static func measure(numberOfIterations: Int, actionBlock: () async -> Void) async -> TimeInterval {
        await measure(numberOfIterations: numberOfIterations, beforeBlock: {}, actionBlock: actionBlock, afterBlock: {})
    }

    /// Measures performance of `actionBlock`
    /// - Parameters:
    ///   - numberOfIterations: number of iterations to run
    ///   - beforeBlock: closure performed before action, not measured into execution time
    ///   - actionBlock: closure to test for execution time
    ///   - afterBlock: closure performed after action, not measured into execution time
    /// - Returns: average execution time per iteration
    static func measure(
        numberOfIterations: Int,
        beforeBlock: () -> Void,
        actionBlock: () async -> Void,
        afterBlock: () -> Void
    ) async -> TimeInterval {
        assert(numberOfIterations > 0)
        var executionTimes = [CFTimeInterval]()
        for _ in 1...numberOfIterations {
            beforeBlock()
            let start = CACurrentMediaTime()
            await actionBlock()
            let executionTime = CACurrentMediaTime() - start
            afterBlock()
            executionTimes.append(executionTime)
        }
        let executionTimeAverage = executionTimes.reduce(0, +) / CFTimeInterval(executionTimes.count)
        return TimeInterval(executionTimeAverage)
    }
}
