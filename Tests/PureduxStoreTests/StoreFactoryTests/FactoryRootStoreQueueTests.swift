//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

import XCTest
@testable import PureduxStore

final class FactoryRootStoreQueueTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatched_ThenObserverCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = factory.rootStore()

        let observer = Observer<TestState> { _, complete in
            complete(.active)

            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
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

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        let store = factory.rootStore()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenActionDispatched_ThenInterceptorCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex),
            interceptor: { _, _  in
                XCTAssertFalse(Thread.isMainThread)
                asyncExpectation.fulfill()
            },
            reducer: { state, action  in
                state.reduce(action: action)
            })

        let store = factory.rootStore()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }
}
