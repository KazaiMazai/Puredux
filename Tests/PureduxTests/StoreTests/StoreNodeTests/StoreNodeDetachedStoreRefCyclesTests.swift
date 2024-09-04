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
    typealias StateComposition = (TestState, ReferenceTypeState)
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>
    typealias ChildStore = any StoreObjectProtocol<StateComposition, Action>

    let rootStore = StateStore<TestState, Action>(
        TestState(currentIndex: 1),
        reducer: { state, action in state.reduce(action: action) }
    )

    func test_WhenStore_ThenWeakRefToChildStoreCreated() {
        var store: AnyStore<StateComposition, Action>?

        assertDeallocated {
            let object = ReferenceTypeState()
            let childStore = self.rootStore.with(
                object,
                reducer: { state, action  in  }
            )

            store = childStore.weakStore()
            return object as AnyObject
        }
    }

    func test_WhenStoreObject_ThenStrongRefToChildStoreCreated() {
        var referencedStore: StateStore<StateComposition, Action>?
        assertNotDeallocated {
            let object = ReferenceTypeState()
            let childStore = self.rootStore.with(
                object,
                reducer: { state, action in  }
            )

            referencedStore = childStore
            return object as AnyObject
        }
    }

    func test_WhenStoreObjectReleased_ThenChildStoreIsReleased() {
        assertDeallocated {
            var referencedStore: StateStore<StateComposition, Action>?
            let object = ReferenceTypeState()
            let childStore = self.rootStore.with(
                object,
                reducer: { state, action  in  }
            )

            referencedStore = childStore
            return object as AnyObject
        }
    }
}
