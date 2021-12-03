//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import PureduxStore

final class RootStoreRefCyclesTests: XCTestCase {
    let timeout: TimeInterval = 3

    func test_WhenGetStore_ThenNoStrongRefToRootStoreCreatedAndObserversAreUnsubscribed() {

        let observerExpectation = expectation(description: "Observer state handler")
        observerExpectation.isInverted = true

        let reducerExpectaion = expectation(description: "Reducer")
        reducerExpectaion.isInverted = true

        let store = RootStore<TestState, Action>(
            initial: TestState(currentIndex: 1)) { state, action  in

            state.reduce(action: action)
            reducerExpectaion.fulfill()

        }.getStore()

        let observer = Observer<TestState> { receivedState, complete in
            complete(.active)
            observerExpectation.fulfill()
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: 100))

        waitForExpectations(timeout: timeout)
    }
}
