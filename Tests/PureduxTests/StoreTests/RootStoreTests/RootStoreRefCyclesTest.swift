//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import Puredux

final class RootStoreRefCyclesTests: XCTestCase {
    let timeout: TimeInterval = 3

    func test_WhenGetStore_ThenNoStrongRefToRootStore() {
        var store: Store<ReferenceTypeState, Action>?

        assertDeallocated {
            let state = ReferenceTypeState()
            let rootStore = StateStore<ReferenceTypeState, Action>(
                state) { state, action  in

                state.reduce(action)
            }

            store = rootStore.weakStore()
            return state as AnyObject
        }
    }
}
