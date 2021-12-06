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

        let expectation = expectation(description: "Reducer")
        expectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreMainQueue_ThenObserverCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let expectation = expectation(description: "Observer state handler")
        expectation.expectedFulfillmentCount = 2

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.store()

        let observer = Observer<TestState> { _, complete in
            complete(.active)

            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreMainQueue_ThenInterceptorCalledOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let expectation = expectation(description: "Reducer")
        expectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            queue: .main,
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        rootStore.interceptActions { _ in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenObserverCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let expectation = expectation(description: "Observer state handler")
        expectation.expectedFulfillmentCount = 2

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.store()

        let observer = Observer<TestState> { _, complete in
            complete(.active)

            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenReducerCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let expectation = expectation(description: "Reducer")
        expectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenStoreDefaultQueue_ThenInterceptorCalledNotOnMainThread() {
        let initialStateIndex = 1
        let stateIndex = 2

        let expectation = expectation(description: "Reducer")
        expectation.expectedFulfillmentCount = 1

        let rootStore = RootStore<TestState, Action>(
            initialState: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        rootStore.interceptActions { _ in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        let store = rootStore.store()

        store.dispatch(UpdateIndex(index: stateIndex))

        waitForExpectations(timeout: timeout)
    }
}

extension RootStoreQueueTests {
    static var allTests = [
        ("test_WhenStoreMainQueue_ThenReducerCalledOnMainThread",
         test_WhenStoreMainQueue_ThenReducerCalledOnMainThread),

        ("test_WhenStoreMainQueue_ThenObserverCalledOnMainThread",
         test_WhenStoreMainQueue_ThenObserverCalledOnMainThread),

        ("test_WhenStoreMainQueue_ThenInterceptorCalledOnMainThread",
         test_WhenStoreMainQueue_ThenInterceptorCalledOnMainThread),

        ("test_WhenStoreDefaultQueue_ThenObserverCalledNotOnMainThread",
         test_WhenStoreDefaultQueue_ThenObserverCalledNotOnMainThread),

        ("test_WhenStoreDefaultQueue_ThenReducerCalledNotOnMainThread",
         test_WhenStoreDefaultQueue_ThenReducerCalledNotOnMainThread),

        ("test_WhenStoreDefaultQueue_ThenInterceptorCalledNotOnMainThread",
         test_WhenStoreDefaultQueue_ThenInterceptorCalledNotOnMainThread)
    ]
}
