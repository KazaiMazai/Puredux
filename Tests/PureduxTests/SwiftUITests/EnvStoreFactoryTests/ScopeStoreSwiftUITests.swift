//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2023.
//

import XCTest
@testable import Puredux
import SwiftUI

@available(iOS 13.0, *)
class ScopeStoreTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: EnvStoreFactory = {
        EnvStoreFactory(
            storeFactory: StoreFactory<TestAppState, Action>(
                initialState: state,
                reducer: { state, action in
                    state.reduce(action)
                })
        )
    }()

    lazy var store: PublishingStore = {
        factory.scopeStore(to: { $0.subStateWithIndex })
    }()

    lazy var rootStore: PublishingStore = {
        factory.rootStore()
    }()
}

@available(iOS 13.0, *)
extension ScopeStoreTests {

    func test_WhenActionDispatchedToScopeStore_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.assertForOverFulfill = false
        let expectedIndex = 100

        var lastReceivedState: Int?
        let cancellable = store.statePublisher.sink { state in
            lastReceivedState = state.index

            receivedState.fulfill()
        }

        store.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(expectedIndex, lastReceivedState)
    }

    func test_WhenActionDispatchedToScopedRootStore_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.assertForOverFulfill = false
        let expectedIndex = 100

        var lastReceivedState: Int?
        let store = rootStore.scope { $0.subStateWithIndex }

        let cancellable = store.statePublisher.sink { state in
            lastReceivedState = state.index

            receivedState.fulfill()
        }

        store.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(expectedIndex, lastReceivedState)
    }

    func test_WhenActionDispatchedToRootStoreProxy_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.assertForOverFulfill = false
        let expectedIndex = 100

        var lastReceivedState: Int?
        let store = rootStore.proxy { $0.subStateWithIndex }

        let cancellable = store.statePublisher.sink { state in
            lastReceivedState = state.index

            receivedState.fulfill()
        }

        store.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(expectedIndex, lastReceivedState)
    }
}
