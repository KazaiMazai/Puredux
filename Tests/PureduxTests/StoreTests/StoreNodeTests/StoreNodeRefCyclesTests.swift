//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import Puredux

final class StoreNodeRootStoreRefCyclesTests: XCTestCase {

    func test_WhenWeakRefStore_ThenWeakRefToRootCreated() {
        var store: AnyStore<TestState, Action>?

        assertDeallocated {
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            store = rootStore.weakRefStore()
            return rootStore as AnyObject
        }
    }

    func test_WhenStoreExists_ThenStrongRefToRootCreated() {
        var store: StateStore<TestState, Action>?

        assertNotDeallocated {
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            store = rootStore.stateStore()
            return rootStore as AnyObject
        }
    }

    func test_WhenStoreRemoved_ThenRootStoreIsReleased() {
        assertDeallocated {
            var store: StateStore<TestState, Action>?
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            store = rootStore.stateStore()
            store = nil
            return rootStore as AnyObject
        }
    }
}
