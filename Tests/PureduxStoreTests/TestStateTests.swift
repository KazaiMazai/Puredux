//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.12.2021.
//

import XCTest
@testable import PureduxStore

final class TestStateTests: XCTestCase {

    func test_WhenStateInitWithValue_ThenIndexEquals() {
        let initialValue = 1
        let state = TestState(currentIndex: initialValue)

        XCTAssertEqual(state.currentIndex, initialValue)
    }

    func test_WhenUpdateIndex_ThenIndexEqualsUpatedValye() {
        let initialIndex = 1
        let newValue = 5
        var state = TestState(currentIndex: initialIndex)

        state.reduce(action: UpdateIndex(index: newValue))

        XCTAssertEqual(state.currentIndex, newValue)
    }
}

extension TestStateTests {
    static var allTests = [
        ("test_WhenStateInitWithValue_ThenIndexEquals",
         test_WhenStateInitWithValue_ThenIndexEquals),

        ("test_WhenUpdateIndex_ThenIndexEqualsUpatedValye",
         test_WhenUpdateIndex_ThenIndexEqualsUpatedValye)
    ]
}
