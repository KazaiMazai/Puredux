//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import PureduxStore

final class CompositionStoreDetachedStoreRefCyclesTests: XCTestCase {
    typealias DetachedStore = CompositionStore<CompositionStore<VoidStore<Action>, TestState, TestState, Action>, DetachedTestState, StateComposition, Action>
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 1),
        reducer: { state, action in state.reduce(action: action) }
    )

    func test_WhenStore_ThenWeakRefToDetachedStoreCreated() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: Store<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakDetachedStore = strongDetachedStore
            store = strongDetachedStore.store()
        }

        XCTAssertNil(weakDetachedStore)
    }

    func test_WhenStoreObject_ThenStrongRefToDetachedStoreCreated() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: StoreObject<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakDetachedStore = strongDetachedStore
            store = strongDetachedStore.storeObject()
        }

        XCTAssertNotNil(weakDetachedStore)
    }

    func test_WhenStoreObjectReleased_ThenDetachedStoreIsReleased() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: StoreObject<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            weakDetachedStore = strongDetachedStore
            store = strongDetachedStore.storeObject()
        }

        store = nil
        XCTAssertNil(weakDetachedStore)
    }
}
