//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import Puredux

final class StateStoreQueueTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenStoreDefaultQueue_ThenObserverCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let observer = Observer<TestState> { _, complete in
            complete(.active)

            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenReducerCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenAsyncActionDefaultQueue_ThenActionExecutionCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Async Action Execution")
        asyncExpectation.expectedFulfillmentCount = 1

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let action = UpdateIndexCallBack(index: stateIndex) {
            XCTAssertTrue(Thread.isMainThread)
            asyncExpectation.fulfill()
        }
        store.dispatch(action)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenAsyncActionSetGlobalQueue_ThenActionExecutionCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Async Action Execution")
        asyncExpectation.expectedFulfillmentCount = 1

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        var action = UpdateIndexCallBack(index: stateIndex) {
            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }
        action.dispatchQueue = .global(qos: .background)
        store.dispatch(action)

        waitForExpectations(timeout: timeout)
    }
}
