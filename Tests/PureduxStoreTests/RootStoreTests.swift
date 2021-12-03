//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import XCTest
@testable import PureduxStore

final class RootStoreTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionsDiptached_ThenReduceOrderPreserved() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
            expectations[state.currentIndex].fulfill()
        }

        let store = rootStore.getStore()

        let actions = (0..<actionsCount).map {
            UpdateIndex(index: $0)
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let expectedStateIndex = 100

        let expectation = expectation(description: "Observer state handler")

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: expectedStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.getStore()

        var receivedStateIndex: Int? = nil

        let observer = Observer<TestState> { receivedState, complete in
            receivedStateIndex = receivedState.currentIndex
            complete(.active)
            expectation.fulfill()
        }

        store.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStateIndex, expectedStateIndex)
        }
    }

    func test_WhenSubscribedAndActionDispatched_ThenInitialAndChangedStateReceived() {
        let initialStateIndex = 1
        let updatedStateIndex = 2

        let expectation = expectation(description: "Observer state handler")
        expectation.expectedFulfillmentCount = 2

        let expectedStateIndexValues = [initialStateIndex, updatedStateIndex]

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.getStore()

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            expectation.fulfill()
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

        let expectation = expectation(description: "Observer state handler")
        expectation.expectedFulfillmentCount = 3

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex]

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.getStore()

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            expectation.fulfill()
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

        let expectation = expectation(description: "Observer state handler")
        expectation.expectedFulfillmentCount = 4

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex, updatedStateIndex]

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.getStore()

        var receivedStatesIndexes: [Int] = []
        let observer = Observer<TestState> { receivedState, complete in
            expectation.fulfill()
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

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
        }

        let store = rootStore.getStore()

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

        let rootStore = RootStore<TestState, Action>(
            initial: TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                stateChangesProcessedExpectation.fulfill()
            }
        }

        let store = rootStore.getStore()

        var observerLastReceivedStateIndex: Int? = nil
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

    static var allTests = [
        ("test_WhenActionsDiptached_ThenReduceOrderPreserved",
         test_WhenActionsDiptached_ThenReduceOrderPreserved),
    ]
}
