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
class RootStoreSwiftUITests: XCTestCase {
    let timeout: TimeInterval = 4

    let initialState = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: EnvStoreFactory = {
        EnvStoreFactory(
            storeFactory: StoreFactory<TestAppState, Action>(
                initialState: initialState,
                reducer: { state, action in
                    state.reduce(action)
                })
        )
    }()

    lazy var store: PublishingStore = {
        factory.rootStore()
    }()
}

@available(iOS 13.0, *)
extension RootStoreSwiftUITests {

    func test_WhenActionDispatched_ThenExpectedStateReceived() {
        let receivedState = expectation(description: "receivedState")
        receivedState.assertForOverFulfill = false
        let expectedIndex = 100

        var lastReceievedState: Int?

        let cancellable = store.statePublisher.sink { state in
            lastReceievedState = state.subStateWithIndex.index
            receivedState.fulfill()
        }

        store.dispatch(UpdateIndex(index: expectedIndex))

        waitForExpectations(timeout: timeout)
        XCTAssertEqual(expectedIndex, lastReceievedState)
    }
}
