//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import XCTest
@testable import Puredux

final class StateStoreTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionsDiptached_ThenReduceOrderPreserved() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
            expectations[state.currentIndex].fulfill()
        }

        let actions = (0..<actionsCount).map {
            UpdateIndex(index: $0)
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenActionsDiptached_ThenInterceptorOrderPreserved() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
        }

        let actions = (0..<actionsCount).map { idx in
            UpdateIndexCallBack(index: idx) {
                expectations[idx].fulfill()
            }
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let expectedStateIndex = 100

        let asyncExpectation = expectation(description: "Observer state handler")

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: expectedStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        var receivedStateIndex: Int?

        let observer = Observer<TestState> { receivedState, complete in
            receivedStateIndex = receivedState.currentIndex
            complete(.active)
            asyncExpectation.fulfill()
        }

        store.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStateIndex, expectedStateIndex)
        }
    }

    func test_WhenSubscribedAndActionDispatched_ThenInitialAndChangedStateReceived() {
        let initialStateIndex = 1
        let updatedStateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let expectedStateIndexValues = [initialStateIndex, updatedStateIndex]

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            asyncExpectation.fulfill()
            receivedStatesIndexes.append(receivedState.currentIndex)
            complete(.active)
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: updatedStateIndex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes, expectedStateIndexValues)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenInitialStateReceivedForEverySubscription() {
        let initialStateIndex = 1

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 3

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex]

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            asyncExpectation.fulfill()
            receivedStatesIndexes.append(receivedState.currentIndex)
            complete(.active)
        }

        store.subscribe(observer: observer)
        store.subscribe(observer: observer)
        store.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes, expectedStateIndexValues)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenSubscribersAreNotDuplicated() {
        let initialStateIndex = 1
        let updatedStateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 4

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex, updatedStateIndex]

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            asyncExpectation.fulfill()
            receivedStatesIndexes.append(receivedState.currentIndex)
            complete(.active)
        }

        store.subscribe(observer: observer)
        store.subscribe(observer: observer)
        store.subscribe(observer: observer)

        store.dispatch(UpdateIndex(index: updatedStateIndex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes, expectedStateIndexValues)
        }
    }

    func test_WhenManyActionsDisptached_ThenObserverReceivesAllStatesInCorrectOrder() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
        }

        let observer = Observer<TestState> { receivedState, complete in
            expectations[receivedState.currentIndex].fulfill()
            complete(.active)
        }

        store.subscribe(observer: observer)

        let actions = (0..<actionsCount).map {
            UpdateIndex(index: $0)
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenObserverCompletesWithDeadStatus_ThenObserverEventuallyGetUnsubscribed() {
        let initialStateIndex = 1
        let stateChangesProcessedExpectation = expectation(description: "State changes processed for sure")

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                stateChangesProcessedExpectation.fulfill()
            }
        }

        var observerLastReceivedStateIndex: Int?
        let observer = Observer<TestState> { receivedState, complete in

            observerLastReceivedStateIndex = receivedState.currentIndex
            complete(.dead)
        }

        store.subscribe(observer: observer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            store.dispatch(UpdateIndex(index: 10))
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(observerLastReceivedStateIndex, initialStateIndex)
        }
    }
}
