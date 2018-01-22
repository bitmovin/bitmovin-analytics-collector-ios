//
//  StateMachineTest.swift
//  BitmovinAnalyticsSampleAppTests
//
//  Created by Cory Zachman on 1/12/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import XCTest
import BitmovinAnalyticsCollector

class StateMachineTest: XCTestCase {
    public var stateMachine:StateMachine
    override func setUp() {
        super.setUp()
        
        self.stateMachine = StateMachine()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        XCTAssertEqual(expression1:
            self.stateMachine.state, expression2: PlayerStateEnum.setup)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
