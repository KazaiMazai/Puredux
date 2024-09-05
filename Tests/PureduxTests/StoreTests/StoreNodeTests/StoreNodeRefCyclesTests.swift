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
        var store: (any Store<ReferenceTypeState, Action>)?

        assertDeallocated {
            let object = ReferenceTypeState()
            let rootStore = StateStore<ReferenceTypeState, Action>(object) { _,_ in }

            store = rootStore.weakStore()
            return object as AnyObject
        }
    }

    func test_WhenStoreExists_ThenStrongRefToRootCreated() {
        var store: AnyStore<ReferenceTypeState, Action>?

        assertNotDeallocated {
            let object = ReferenceTypeState()
            let rootStore = StateStore<ReferenceTypeState, Action>(object) { _,_ in }

            store = rootStore.eraseToAnyStore()
            return object as AnyObject
        }
    }

    func test_WhenStoreRemoved_ThenRootStoreIsReleased() {
        assertDeallocated {
            var store: AnyStore<ReferenceTypeState, Action>?
            let object = ReferenceTypeState()
            let rootStore = StateStore<ReferenceTypeState, Action>(object) { _,_ in }

            store = rootStore.eraseToAnyStore()
            store = nil
            return object as AnyObject
        }
    }
}
