//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import PureduxStore

final class StoreNodeRootStoreRefCyclesTests: XCTestCase {
    let timeout: TimeInterval = 3

    func test_WhenStore_ThenWeakRefToRootCreated() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: Store<TestState, Action>?

        autoreleasepool {
            let strongRootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            weakRootStore = strongRootStore
            store = strongRootStore.store()
        }

        XCTAssertNil(weakRootStore)
    }

    func test_WhenStoreObject_ThenStrongRefToRootCreated() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: StoreObject<TestState, Action>?

        autoreleasepool {
            let strongRootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            weakRootStore = strongRootStore
            store = strongRootStore.storeObject()
        }

        XCTAssertNotNil(weakRootStore)
    }

    func test_WhenStoreObjectReleased_ThenRootStoreIsReleased() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: StoreObject<TestState, Action>?

        autoreleasepool {
            let strongRootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            weakRootStore = strongRootStore
            store = strongRootStore.storeObject()
        }

        store = nil
        XCTAssertNil(weakRootStore)
    }
}
