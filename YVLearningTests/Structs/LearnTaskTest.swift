//
//  LearnTaskTest.swift
//  YVLearningTests
//
//  Created by Yash Vyas on 12/02/22.
//

import XCTest
@testable import YVLearning

class LearnTaskTest: XCTestCase {
    func testInit() {
        let sut = LearnTask()
        XCTAssertNotNil(sut)
    }
}
