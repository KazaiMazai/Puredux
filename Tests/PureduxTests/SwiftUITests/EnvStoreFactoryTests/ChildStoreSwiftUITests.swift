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
class ChildStoreSwiftUITests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    let initialChildState = SubStateWithIndex(index: 1)

    lazy var factory: EnvStoreFactory = {
        EnvStoreFactory(
            storeFactory: StoreFactory<TestAppState, Action>(
                initialState: state,
                reducer: { state, action in state.reduce(action)}
            )
        )
    }()

    lazy var rootStore: PublishingStore = {
        factory.rootStore()
    }()

    lazy var childStoreObject: PublishingStoreObject<(TestAppState, SubStateWithIndex), Action> = {
        factory.childStore(
            initialState: initialChildState,
            reducer: { state, action in state.reduce(action)}
        )
    }()

    lazy var childStore: PublishingStore = {
        childStoreObject.store()
    }()
}

@available(iOS 13.0, *)
extension ChildStoreSwiftUITests {
    func test_WhenActionDispatchedToRootStore_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.assertForOverFulfill = false
        let expectedIndex = 100

        var lastAppStateIndex: Int?
        var lastChildStateIndex: Int?

        let cancellable = childStore.statePublisher.sink { (appState, childState) in
            lastAppStateIndex = appState.subStateWithIndex.index
            lastChildStateIndex = childState.index

            receivedState.fulfill()
        }

        rootStore.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(expectedIndex, lastAppStateIndex)
        XCTAssertEqual(initialChildState.index, lastChildStateIndex)
    }

    func test_WhenActionDispatchedToChildStore_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.expectedFulfillmentCount = 1
        let expectedIndex = 100

        var lastAppStateIndex: Int?
        var lastChildStateIndex: Int?

        let cancellable = childStore.statePublisher.sink { (appState, childState) in
            lastAppStateIndex = appState.subStateWithIndex.index
            lastChildStateIndex = childState.index

            guard lastAppStateIndex == expectedIndex,
                  lastChildStateIndex == expectedIndex else {
                return
            }
            receivedState.fulfill()
        }

        childStore.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(expectedIndex, lastAppStateIndex)
        XCTAssertEqual(expectedIndex, lastChildStateIndex)
    }
}

