//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

import XCTest
@testable import Puredux

final class FactoryStateStoreQueueTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatched_ThenObserverCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let observer = Observer<TestState> { _ in
            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
            return .active
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenActionDispatched_ThenReducerCalledNotOnMainThread() {
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

    func test_WhenActionQueueIsSetToGlobal_ThenInterceptorCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let store = StateStore<TestState, Action>(
            TestState(currentIndex: initialStateIndex),
            reducer: { state, action  in
                state.reduce(action: action)
            })

        var action = AsyncResultAction(index: stateIndex) { _ in
            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        action.dispatchQueue = .global(qos: .default)

        store.dispatch(action)

        waitForExpectations(timeout: timeout)
    }
}
