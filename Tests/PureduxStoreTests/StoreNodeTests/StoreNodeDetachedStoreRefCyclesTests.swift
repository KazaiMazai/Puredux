//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import PureduxStore

final class StoreNodeChildStoreRefCyclesTests: XCTestCase {
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>
    typealias ChildStore = StoreNode<ParentStore, ChildTestState, StateComposition, Action>

    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 1),
        reducer: { state, action in state.reduce(action: action) }
    )

    func test_WhenStore_ThenWeakRefToChildStoreCreated() {
        weak var weakChildStore: ChildStore?
        var store: Store<StateComposition, Action>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            store = strongChildStore.store()
        }

        XCTAssertNil(weakChildStore)
    }

    func test_WhenStoreObject_ThenStrongRefToChildStoreCreated() {
        weak var weakChildStore: ChildStore?
        var store: StoreObject<StateComposition, Action>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            store = strongChildStore.storeObject()
        }

        XCTAssertNotNil(weakChildStore)
    }

    func test_WhenStoreObjectReleased_ThenChildStoreIsReleased() {
        weak var weakChildStore: ChildStore?
        var store: StoreObject<StateComposition, Action>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            store = strongChildStore.storeObject()
        }

        store = nil
        XCTAssertNil(weakChildStore)
    }
}
