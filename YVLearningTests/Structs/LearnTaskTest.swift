//
//  LearnTaskTest.swift
//  YVLearningTests
//
//  Created by Yash Vyas on 12/02/22.
//

import Testing
@testable import YVLearning

@Suite(.serialized)
class LearnTaskTest {
    @Test func initialization() throws {
        let sut = try #require(LearnTask())
        withKnownIssue(isIntermittent: true) {
            #expect(sut != nil)
        }
    }
}
