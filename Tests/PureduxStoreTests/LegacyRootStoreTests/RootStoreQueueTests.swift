//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import PureduxStore

final class RootStoreQueueTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenStoreMainQueue_ThenReducerCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertTrue(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreMainQueue_ThenObserverCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.store()

        let observer = Observer<TestState> { _, complete in
            complete(.active)

            XCTAssertTrue(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreMainQueue_ThenInterceptorCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        rootStore.interceptActions { _ in
            XCTAssertTrue(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenObserverCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.store()

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

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenInterceptorCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let asyncExpectation = expectation(description: "Reducer")
        asyncExpectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        rootStore.interceptActions { _  in
            XCTAssertFalse(Thread.isMainThread)
            asyncExpectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }
}
