//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 23.02.2023.
//

import XCTest
@testable import PureduxStore

final class DetachedStoreTests: XCTestCase {
    let timeout: TimeInterval = 10

    let initialState = StateComposition(
        state: TestState(currentIndex: 0),
        detachedState: DetachedTestState(currentIndex: 0)
    )

    lazy var factory = {
        StoreFactory<TestState, Action>(
            initialState: initialState.state) { state, action  in

                state.reduce(action: action)
            }
    }()

    lazy var detachedStore = {
        factory.detachedStore(
            initialState: initialState.detachedState,
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )
    }()

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let asyncExpectation = expectation(description: "Observer state handler")

        var receivedState: StateComposition?

        let observer = Observer<StateComposition> { state, complete in
            receivedState = state
            complete(.active)
            asyncExpectation.fulfill()
        }

        detachedStore.subscribe(observer: observer)

        let initialState = initialState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedState, initialState)
        }
    }

    func test_WhenSubscribedAndActionDispatched_ThenInitialAndStateChangesReceivedTwice() {
        let expectedState = StateComposition(
            state: TestState(currentIndex: 2),
            detachedState: DetachedTestState(currentIndex: 2)
        )

        var lastReceivedState: StateComposition?

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 3

        let observer = Observer<StateComposition> { receivedState, complete in
            asyncExpectation.fulfill()
            lastReceivedState = receivedState
            complete(.active)
        }

        detachedStore.subscribe(observer: observer)
        detachedStore.dispatch(UpdateIndex(index: 2))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState, expectedState)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenInitialStateReceivedForEverySubscription() {
        var receivedStatesIndexes: [StateComposition] = []

        let expectedReceivedStates = [initialState, initialState, initialState]

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 3

        let observer = Observer<StateComposition> { receivedState, complete in
            asyncExpectation.fulfill()
            receivedStatesIndexes.append(receivedState)
            complete(.active)
        }

        detachedStore.subscribe(observer: observer)
        detachedStore.subscribe(observer: observer)
        detachedStore.subscribe(observer: observer)

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedStatesIndexes, expectedReceivedStates)
        }
    }

    func test_WhenSubscribedMultipleTimes_ThenSubscribersAreNotDuplicated() {
        let expectedIndex = 2
        let expectedState = StateComposition(
            state: TestState(currentIndex: expectedIndex),
            detachedState: DetachedTestState(currentIndex: expectedIndex)
        )

        var lastReceivedState: StateComposition?

        let asyncExpectation = expectation(description: "Observer state handler")
        asyncExpectation.expectedFulfillmentCount = 5

        let observer = Observer<StateComposition> { receivedState, complete in
            asyncExpectation.fulfill()
            lastReceivedState = receivedState
            complete(.active)
        }

        detachedStore.subscribe(observer: observer)
        detachedStore.subscribe(observer: observer)
        detachedStore.subscribe(observer: observer)
        detachedStore.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState, expectedState)
        }
    }

    func test_WhenObserverCompletesWithDeadStatus_ThenObserverEventuallyGetUnsubscribed() {
        var lastReceivedState: StateComposition?
        let unsubscriptionProcessedExpectation = expectation(description: "Unsubscription processed for sure")

        let observer = Observer<StateComposition> { state, complete in

            lastReceivedState = state
            complete(.dead)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                unsubscriptionProcessedExpectation.fulfill()
            }
        }

        detachedStore.subscribe(observer: observer)
        let detachedStore = detachedStore

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            detachedStore.dispatch(UpdateIndex(index: 10))
        }

        let initialState = initialState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(lastReceivedState, initialState)
        }
    }
}
 
final class DetachedStoreWithoutStateMappingTests: XCTestCase {
    let timeout: TimeInterval = 10

    let initialState = TestState(currentIndex: 0)
    let initialDetachedState = DetachedTestState(currentIndex: 0)

    lazy var factory = {
        StoreFactory<TestState, Action>(
            initialState: initialState) { state, action  in

                state.reduce(action: action)
            }
    }()

    lazy var detachedStore = {
        factory.detachedStore(
            initialState: initialDetachedState,
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )
    }()

    func test_WhenSubscribed_ThenCurrentStateReceived() {
        let asyncExpectation = expectation(description: "Observer state handler")

        var receivedState: (root: TestState, local: DetachedTestState)?

        let observer = Observer<(TestState, DetachedTestState)> { state, complete in
            receivedState = state
            complete(.active)
            asyncExpectation.fulfill()
        }

        detachedStore.subscribe(observer: observer)

        let initialState = initialState
        let initialDetachedState = initialDetachedState
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(receivedState!.root, initialState)
            XCTAssertEqual(receivedState!.local, initialDetachedState)
        }
    }
}
