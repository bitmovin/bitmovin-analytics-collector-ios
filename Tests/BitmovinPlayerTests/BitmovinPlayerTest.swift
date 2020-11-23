//
//  CoreTests_iOS.swift
//  CoreTests-iOS
//
//  Created by Roland Grießer on 17.11.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import BitmovinAnalyticsCollector

class CoreTests_iOS: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let position = BitmovinPlayerUtil.getAdPositionFromString(string: "pre")
        XCTAssertEqual(position, AdPosition.pre)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

