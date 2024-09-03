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
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>
    typealias ChildStore = any StoreObjectProtocol<StateComposition, Action>

    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 1),
        reducer: { state, action in state.reduce(action: action) }
    )

    func test_WhenStore_ThenWeakRefToChildStoreCreated() {
        var store: Store<StateComposition, Action>?

        assertDeallocated {
            let strongChildStore = self.rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
 
            store = strongChildStore.weakRefStore()
            return strongChildStore as AnyObject
        }
    }

    func test_WhenStoreObject_ThenStrongRefToChildStoreCreated() {
        var referencedStore: StateStore<StateComposition, Action>?
        assertNotDeallocated {
            let strongChildStore = self.rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
 
            referencedStore = strongChildStore.stateStore()
            return strongChildStore as AnyObject
        }
    }

    func test_WhenStoreObjectReleased_ThenChildStoreIsReleased() {
        assertDeallocated {
            var referencedStore: StateStore<StateComposition, Action>?
            let strongChildStore = self.rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
 
            referencedStore = strongChildStore.stateStore()
            return strongChildStore as AnyObject
        }
    }
}
