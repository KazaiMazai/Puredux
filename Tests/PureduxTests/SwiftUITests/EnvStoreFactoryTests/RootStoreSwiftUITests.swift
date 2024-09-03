//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2023.
//

import XCTest
@testable import Puredux
import SwiftUI

/*
class StateStoreSwiftUITests: XCTestCase {
    let timeout: TimeInterval = 4

    let initialState = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: StateStore = {
        StateStore(
            storeFactory: StateStore<TestAppState, Action>(
                 initialState,
                reducer: { state, action in
                    state.reduce(action)
                })
        )
    }()

    lazy var store: Store = {
        factory.StateStore()
    }()
}


extension StateStoreSwiftUITests {

    func test_WhenActionDispatched_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        let expectedIndex = 100

        var lastReceievedState: Int?

        let cancellable = store.statePublisher.sink { state in
            lastReceievedState = state.subStateWithIndex.index
            if lastReceievedState == expectedIndex {
                receivedState.fulfill()
            }
        }

        store.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(expectedIndex, lastReceievedState)
    }
}
*/
