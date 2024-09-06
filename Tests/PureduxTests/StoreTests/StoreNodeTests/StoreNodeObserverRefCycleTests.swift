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
    let rootStore = StateStore<TestState, Action>(
        TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreAndObserverLive_ThenReferencCycleIsCreated() {

        assertNotDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.with(
                object,
                reducer: { state, action  in  state.reduce(action) }
            ).map { $1 }

            
            let observer = Observer<ReferenceTypeState> { _, complete in
                store.dispatch(UpdateIndex(index: 1))
                return .active
            }

            store.subscribe(observer: observer)
            return object as AnyObject
        }
    }

    func test_WhenStrongRefToStoreAndObserverDead_ThenStoreIsReleased() {
        assertDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.with(
                object,
                reducer: { state, action in state.reduce(action) }
            ).map { $1 }

            let observer = Observer<ReferenceTypeState> { _, complete in
                store.dispatch(UpdateIndex(index: 1))
                return .dead
            }

            store.subscribe(observer: observer)
            return object as AnyObject
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        assertDeallocated {
            let object = ReferenceTypeState()
            let store = self.rootStore.with(
                object,
                reducer: { state, action  in  state.reduce(action) }
            ).map { $1 }

            let weakStore = store.weakStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                weakStore.dispatch(UpdateIndex(index: 1))
                return .active
            }

            store.subscribe(observer: observer)
            return object as AnyObject
        }
    }
}
