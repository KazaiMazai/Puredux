//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import Puredux

final class StoreNodeChildStoreObserverRefCycleTests: XCTestCase {
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>

    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreAndObserverLive_ThenReferencCycleIsCreated() {

        assertNotDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.createChildStore(
                initialState: object,
                stateMapping: { _, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )

            let referencedStore = store.stateStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            referencedStore.subscribe(observer: observer)
            return object as AnyObject
        }
    }

    func test_WhenStrongRefToStoreAndObserverDead_ThenStoreIsReleased() {
        assertDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.createChildStore(
                initialState: object,
                stateMapping: { _, childState in childState },
                reducer: { state, action in state.reduce(action) }
            )

            let referencedStore = store.stateStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
            }

            referencedStore.subscribe(observer: observer)
            return object as AnyObject
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        assertDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.createChildStore(
                initialState: object,
                stateMapping: { _, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )

            let weakRefStore = store.weakRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                weakRefStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            store.subscribe(observer: observer)
            return object as AnyObject
        }
    }
}
