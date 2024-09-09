//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 23.02.2023.
//

import XCTest
@testable import Puredux

final class ChildStoreTests: XCTestCase {
    let timeout: TimeInterval = 10

    let initialState = StateComposition(
        state: TestState(currentIndex: 0),
        childState: ChildTestState(currentIndex: 0)
    )

    lazy var stateStore = {
        StateStore<TestState, Action>(
             initialState.state) { state, action  in

                state.reduce(action: action)
            }
    }()

    lazy var childStore = {
        stateStore.with(
             initialState.childState,
             reducer: { state, action  in
                 state.reduce(action: action)
             }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }
    }()

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let asyncExpectation = expectation(description: "Observer state handler")

        let receivedState = UncheckedReference<StateComposition?>(nil)

        let observer = Observer<StateComposition> { state in
            receivedState.value = state
            asyncExpectation.fulfill()
            return .active
        }

        childStore.subscribe(observer: observer)

        let initialState = initialState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedState.value, initialState)
        }
    }

    func test_WhenSubscribedAndActionDispatched_ThenInitialAndStateChangesReceivedTwice() {
        let expectedState = StateComposition(
            state: TestState(currentIndex: 2),
            childState: ChildTestState(currentIndex: 2)
        )

        let lastReceivedState = UncheckedReference<StateComposition?>(nil)
        
        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 2

        let observer = Observer<StateComposition> { receivedState in
            asyncExpectation.fulfill()
            lastReceivedState.value = receivedState
            return .active
        }

        childStore.subscribe(observer: observer)
        childStore.dispatch(UpdateIndex(index: 2))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState.value, expectedState)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenInitialStateReceivedForEverySubscription() {
        let receivedStatesIndexes = UncheckedReference<[StateComposition]>([])
        let expectedReceivedStates = [initialState, initialState, initialState]

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 3

        let observer = Observer<StateComposition> { receivedState in
            asyncExpectation.fulfill()
            receivedStatesIndexes.value.append(receivedState)
            return .active
        }

        childStore.subscribe(observer: observer)
        childStore.subscribe(observer: observer)
        childStore.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes.value, expectedReceivedStates)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenSubscribersAreNotDuplicated() {
        let expectedIndex = 2
        let expectedState = StateComposition(
            state: TestState(currentIndex: expectedIndex),
            childState: ChildTestState(currentIndex: expectedIndex)
        )

        let lastReceivedState = UncheckedReference<StateComposition?>(nil)
        
        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 4

        let observer = Observer<StateComposition> { receivedState in
            asyncExpectation.fulfill()
            lastReceivedState.value = receivedState
            return .active
        }

        childStore.subscribe(observer: observer)
        childStore.subscribe(observer: observer)
        childStore.subscribe(observer: observer)
        childStore.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState.value, expectedState)
        }
    }

    func test_WhenObserverCompletesWithDeadStatus_ThenObserverEventuallyGetUnsubscribed() {
        let lastReceivedState = UncheckedReference<StateComposition?>(nil)
        
        let unsubscriptionProcessedExpectation = expectation(description: "Unsubscription processed for sure")

        let observer = Observer<StateComposition> { state in

            lastReceivedState.value = state
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                unsubscriptionProcessedExpectation.fulfill()
            }
            return .dead
        }

        childStore.subscribe(observer: observer)
        let childStore = childStore

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            childStore.dispatch(UpdateIndex(index: 10))
        }

        let initialState = initialState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState.value, initialState)
        }
    }
}

final class ChildStoreWithoutStateMappingTests: XCTestCase {
    let timeout: TimeInterval = 10

    let initialState = TestState(currentIndex: 0)
    let initialChildState = ChildTestState(currentIndex: 0)

    lazy var stateStore = {
        StateStore<TestState, Action>(
             initialState) { state, action  in

                state.reduce(action: action)
            }
    }()

    lazy var childStore = {
        stateStore.with(
             initialChildState,
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )
    }()

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let asyncExpectation = expectation(description: "Observer state handler")
        let receivedState = UncheckedReference<(root: TestState, local: ChildTestState)?>(nil)

        let observer = Observer<(TestState, ChildTestState)> { state in
            receivedState.value = state
            asyncExpectation.fulfill()
            return .active
        }

        childStore.subscribe(observer: observer)

        let initialState = initialState
        let initialChildState = initialChildState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedState.value!.root, initialState)
            XCTAssertEqual(receivedState.value!.local, initialChildState)
        }
    }
}
