//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import Puredux

@available(iOS 16.0.0, *)
final class StoreNodeChildStoreRefCyclesTests: XCTestCase {
    typealias ParentStore = StoreNode<VoidStore<AppAction>, TestState, TestState, AppAction>
    typealias ChildStore = any StoreProtocol<StateComposition, AppAction>

    let rootStore = RootStoreNode<TestState, AppAction>.initRootStore(
        initialState: TestState(currentIndex: 1),
        reducer: { state, action in state.reduce(action: action) }
    )

    func test_WhenStore_ThenWeakRefToChildStoreCreated() {
        weak var weakChildStore: ChildStore?
        var store: Store<StateComposition, AppAction>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                qos: .userInitiated,
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            store = strongChildStore.weakRefStore()
        }

        XCTAssertNil(weakChildStore)
    }

    func test_WhenStoreObject_ThenStrongRefToChildStoreCreated() {
        weak var weakChildStore: ChildStore?
        var referencedStore: StateStore<StateComposition, AppAction>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                qos: .userInitiated,
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            referencedStore = strongChildStore.stateStore()
        }

        XCTAssertNotNil(weakChildStore)
    }

    func test_WhenStoreObjectReleased_ThenChildStoreIsReleased() {
        weak var weakChildStore: ChildStore?
        var referencedStore: StateStore<StateComposition, AppAction>?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                qos: .userInitiated,
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakChildStore = strongChildStore
            referencedStore = strongChildStore.stateStore()
        }

        referencedStore = nil
        XCTAssertNil(weakChildStore)
    }
}
