@testable import CoreCollector
import Foundation
import Nimble
import Quick

class EventDataKeyTests: QuickSpec {
    override class func spec() {
        let testData = [
            "10.0#C755E643-6777".base64: EventDataKey(sessionId: "C755E643-6777", creationTime: 10),
            "20.0####".base64: EventDataKey(sessionId: "###", creationTime: 20),
            "30.0#foo-bar".base64: EventDataKey(sessionId: "foo-bar", creationTime: 30),
            "40.0##123#".base64: EventDataKey(sessionId: "#123#", creationTime: 40),
            "50.0#123".base64: EventDataKey(sessionId: "123", creationTime: 50),
        ]

        describe("encoding") {
            testData.forEach { (base64, eventDataKey) in
                it("encodes the given EventDataKey to the correct base64 String") {
                    expect(eventDataKey.description).to(equal(base64))
                }
            }
        }
        describe("decoding") {
            testData.forEach { (base64, eventDataKey) in
                it("decodes the given base64 String to the correct EventDataKey") {
                    let decoded = EventDataKey(base64)

                    expect(decoded?.creationTime).to(equal(eventDataKey.creationTime))
                    expect(decoded?.sessionId).to(equal(eventDataKey.sessionId))
                }
            }
        }
    }
}

private extension String {
    var base64: String {
        Data(self.utf8).base64EncodedString()
    }
}
