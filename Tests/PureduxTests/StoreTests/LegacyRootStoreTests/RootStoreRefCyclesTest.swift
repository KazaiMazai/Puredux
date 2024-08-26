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
        var store: Store<TestState, Action>?

        assertDeallocated {
            let rootStore = RootStore<TestState, Action>(
                initialState: TestState(currentIndex: 1)) { state, action  in

                state.reduce(action: action)
            }

            store = rootStore.store()
            return rootStore as AnyObject
        }
    }
}
