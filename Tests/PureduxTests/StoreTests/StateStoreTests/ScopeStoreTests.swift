//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation
import XCTest
@testable import Puredux

final class ScopedStoreTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionsDiptachedToScopedStore_ThenDispatchOrderPreserved() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
            expectations[state.currentIndex].fulfill()
        }

        let store = stateStore.map { $0.currentIndex }

        let actions = (0..<actionsCount).map {
            UpdateIndex(index: $0)
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenSubscribedToScopedStore_ThenCurrentStateReceived() {
        let expectedStateIndex = 100

        let asyncExpectation = expectation(description: "Observer state handler")

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: expectedStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = stateStore.map { $0.currentIndex }

        let receivedStateIndex = UncheckedReference<Int?>(nil)

        let observer = Observer<Int> { receivedState in
            receivedStateIndex.value = receivedState
            asyncExpectation.fulfill()
            return .active
        }

        store.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStateIndex.value, expectedStateIndex)
        }
    }

    func test_WhenActionDispatchedToScopedStore_ThenStateReceived() {
        let initialStateIndex = 1
        let updatedStateindex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let expectedStateIndexValues = [initialStateIndex, updatedStateindex]

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = stateStore.map { $0.currentIndex }

        let receivedStatesIndexes = UncheckedReference<[Int]>([])
        let observer = Observer<Int> { receivedState in
            asyncExpectation.fulfill()
            receivedStatesIndexes.value.append(receivedState)
            return .active
        }

        store.subscribe(observer: observer)
        store.dispatch(UpdateIndex(index: updatedStateindex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes.value, expectedStateIndexValues)
        }
    }

    func test_WhenSubscribedMultipleTimesToScopedStore_ThenInitialStateReceivedForEverySubscription() {
        let initialStateIndex = 1

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 3

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex]

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = stateStore.map { $0.currentIndex }

        let receivedStatesIndexes = UncheckedReference<[Int]>([])
        let observer = Observer<Int> { receivedState in
            asyncExpectation.fulfill()
            receivedStatesIndexes.value.append(receivedState)
            return .active
        }

        store.subscribe(observer: observer)
        store.subscribe(observer: observer)
        store.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes.value, expectedStateIndexValues)
        }
    }

    func test_WhenSubscribedMultipleTimesToScopedStore_ThenSubscribersAreNotDuplicated() {
        let initialStateIndex = 1
        let updatedStateIndex = 2

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 4

        let expectedStateIndexValues = [initialStateIndex, initialStateIndex, initialStateIndex, updatedStateIndex]

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)
        }

        let store = stateStore.map { $0.currentIndex }

        let receivedStatesIndexes = UncheckedReference<[Int]>([])
        let observer = Observer<Int> { receivedState in
            asyncExpectation.fulfill()
            receivedStatesIndexes.value.append(receivedState)
            return .active
        }

        store.subscribe(observer: observer)
        store.subscribe(observer: observer)
        store.subscribe(observer: observer)

        store.dispatch(UpdateIndex(index: updatedStateIndex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes.value, expectedStateIndexValues)
        }
    }

    func test_WhenManyActionsDisptachedToScopedStore_ThenObserverReceivesAllStatesInCorrectOrder() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
        }

        let store = stateStore.map { $0.currentIndex }

        let observer = Observer<Int> { receivedState in
            expectations[receivedState].fulfill()
            return .active
        }

        store.subscribe(observer: observer)

        let actions = (0..<actionsCount).map {
            UpdateIndex(index: $0)
        }

        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenObserverCompleteWithDeadStatus_ThenObserverEventuallyGetUnsubscribed() {
        let initialStateIndex = 1
        let stateChangesProcessedExpectation = expectation(
            description: "Actions and State changes processed for sure")

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: initialStateIndex)) { state, action  in

            state.reduce(action: action)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                stateChangesProcessedExpectation.fulfill()
            }
        }

        let store = stateStore.map { $0.currentIndex }

        let observerLastReceivedStateIndex = UncheckedReference<Int?>(nil)
        let observer = Observer<Int> { receivedState in
            observerLastReceivedStateIndex.value = receivedState
            return .dead
        }

        store.subscribe(observer: observer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            store.dispatch(UpdateIndex(index: 10))
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(observerLastReceivedStateIndex.value, initialStateIndex)
        }
    }
}

final class ScopedStoreOptionalStateTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenStoreWithOptionalStateAndScopeStateIsNill_ThenStateUpdatesReceived() {

        let receivedExpectation = expectation(description: "Observer state handler")

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: 0)) { state, action  in

            state.reduce(action: action)
        }

        let store: StateStore<Int?, Action> = stateStore.flatMap { _  in nil }

        let observer = Observer<Int?> { _ in
            receivedExpectation.fulfill()
            return .active
        }

        store.subscribe(observer: observer)
        wait(for: [receivedExpectation], timeout: timeout)
    }
}
